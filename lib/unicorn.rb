# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/www/swiftwatch"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/www/swiftwatch/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/logs/unicorn.log"
# stdout_path "/path/to/logs/unicorn.log"
stderr_path "/www/swiftwatch/logs/unicorn.log"
stdout_path "/www/swiftwatch/logs/unicorn.log"

# Unicorn socket
# listen "/tmp/unicorn.[app name].sock"
listen "/tmp/unicorn.myapp.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30

# worker_processes Integer(ENV['UNICORN_WORKERS'] || 4)
# timeout 30
# preload_app true
# listen(ENV['PORT'] || 3000, :backlog => Integer(ENV['UNICORN_BACKLOG'] || 200))

# before_fork do |server, worker|
#   Signal.trap 'TERM' do
#     puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
#     Process.kill 'QUIT', Process.pid
#   end

#   if defined?(Sequel::Model)
#     Sequel::DATABASES.each{ |db| db.disconnect }
#   end
# end

# after_fork do |server, worker|
#   Signal.trap 'TERM' do
#     puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
#   end
# end
