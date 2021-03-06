$           = jQuery
Controller  = require('controller')
helpers     = require('app/helpers')
State       = require('app/state')
User        = require('app/models/user')
Post        = require('app/models/post')
Comments    = require('app/controllers/comments')
UserProfile = require('app/controllers/users/profile')
Details     = require('app/controllers/posts/details')
Landing     = require('app/controllers/posts/landing')
withUser    = State.withActiveUser

class Posts extends Controller
  className: 'posts-show'

  constructor: ->
    super

    @$el.activeArea()
    @on 'click', 'a[data-user-id]', @clickUser
    @on 'click', 'a[data-delete-post]', @deletePost
    @on 'click', 'a[data-flag-post]', @flagPost

    State.observeKey 'post', =>
      @render(State.get('post'))

  deletePost: (e) =>
    e.preventDefault()
    
    postID = $(e.currentTarget).data('delete-post')
    return unless postID

    if confirm("Do you really want to delete this post?") == true
      Post.delete(postID)

  flagPost: (e) =>
    e.preventDefault()
    
    postID = $(e.currentTarget).data('flag-post')
    return unless postID

    if confirm("Do you really want to report this post as offensive?") == true
      Post.flag(postID)

  render: (@post) =>
    @$el.empty()

    if @post
      @append(@details  = new Details(post: @post))
      @append(@comments = new Comments(post: @post))
    else
      @append(@landing = new Landing)

  # Private

  clickUser: (e) =>
    e.preventDefault()

    userID = $(e.currentTarget).data('user-id')
    return unless userID

    user   = User.find(userID)
    UserProfile.open(user)

module.exports = Posts
