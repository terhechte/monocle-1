module Brisk
  module Routes
    class Posts < Base
      get '/v1/posts' do
        json Post.published.limit(
          params[:limit] || 30,
          params[:offset]
        )
      end

      get '/v1/posts/popular' do
        json Post.published.limit(
          params[:limit] || 30,
          params[:offset]
        )
      end

      post '/v1/posts/popular' do
        json Post.published.paginate(params[:ignore], 30)
      end

      get '/v1/posts/flagged', :auth => true do
        if !current_user.admin?
          return json []
        end
        #json Post.published.paginate(params[:ignore], 30)
        json Post.published.flagged.paginate(params[:ignore], 300)
      end

      get '/v1/posts/newest' do
        json Post.published.newest.limit(
          params[:limit] || 30,
          params[:offset]
        )
      end

      post '/v1/posts/newest' do
        json Post.published.newest.paginate(params[:ignore], 30)
      end

      get '/v1/posts/search' do
        json Post.published.search(params[:q]).limit(30)
      end

      get '/v1/posts/slug/:slug' do
        begin
          json Post.first!(slug: params[:slug])
        rescue Exception
          return json Post.newest()[0]
        end
      end

      get '/v1/posts/suggest_title' do
        begin
          document = Nestful.get(params[:url], {}, timeout: 2).body
        rescue Nestful::TimeoutError, URI::InvalidURIError
          # Return an empty title
          json(title: nil)
        end

        title = Parsers::OpenGraph.parse(document)[:title]
        title ||= Parsers::HTMLTitle.parse(document)
        json(title: title)
      end

      get '/v1/posts/:id' do
        json Post.first!(id: params[:id])
      end

      post '/v1/posts/:id/visit' do
        post = Post.first!(id: params[:id])
        post.visit!(current_user)
        json post
      end

      get '/v1/posts/:id/visit' do
        post = Post.first!(id: params[:id])
        redirect post.url
      end

      post '/v1/posts', :auth => true do
        existing = Post.today.url(params[:url]).first

        if existing
          existing.vote!(current_user)
          return json(existing)
        end

        post = Post.new
        post.set_fields(params, [:title, :url])
        post.user   = current_user
        post.notify = true

        begin
          post.save!
        rescue Exception
          return json("Invalid URL")
        end

        post.vote!(post.user)

        begin
          post.retrieve!
        rescue Nestful::ConnectionError => e
          logger.error e
        end

        publish [:posts, :create], id: post.id
        json post
      end

      post '/v1/posts/:id/vote', :auth => true do
        post = Post.first!(id: params[:id])
        post.vote!(current_user)

        publish [:posts, :vote], id: post.id

        json post
      end

      get '/v1/posts/:id/comments' do
        content_type :json

        fragment do
          post     = Post.first!(id: params[:id])
          comments = post.comments_dataset

          if params[:threaded]
            json comments.root.ordered, threaded: true
          else
            json comments.ordered
          end
        end
      end

      post '/v1/posts/:id/comments', :auth => true do
        post         = Post.first!(id: params[:id])
        comment      = Comment.new
        comment.post = post
        comment.user = current_user
        comment.set_fields(params, [:body, :parent_id])

        comment.save!
        comment.vote!(comment.user)

        publish [:posts, :comments, :create],
                comment_id: comment.id,
                post_id: post.id
        json comment
      end

      get '/v1/posts/:id/body' do
        @post = Post.first!(id: params[:id])
        erb :post_body
      end

      post '/v1/posts/delete/:id', :auth => true do
        post = Post.first!(id: params[:id])

        # make sure we're the owning user
        if current_user.id != post.user_id and !current_user.admin?
          return "Invalid user"
        end

        # remove all comments
        comments = post.comments_dataset
        comments.each { |k|
          k.comment_votes.each { |v|
            v.destroy
          }
          k.destroy
        }
        post.post_votes_dataset.each { |k|
          k.destroy
        }
        post.post_visits_dataset.each { |k|
          k.destroy
        }
        post.delete
        "done"
      end

      post '/v1/posts/flag/:id', :auth => true do
        post = Post.first!(id: params[:id])
        post.flagged += 1
        post.save
      end

      get '/feed' do
        @posts = Post.published.limit(50)
        builder :feed
      end
    end
  end
end
