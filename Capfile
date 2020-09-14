# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require "capistrano/rails"

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

set :repo_url, "git@github.com:uwmadison-chm/hedonometer.git"

#set :pty, true

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'
append :linked_files, 'config/database.yml', 'config/secrets.yml', 'public/.htaccess'

set :puma_init_active_record, true

namespace :deploy do
  after :finishing, :restart
  desc 'Restart puma by killing it'
  task :restart do
    on roles(:app) do
      execute 'kill `cat /var/www/apps/h2/shared/tmp/pids/puma.pid`'
    end
  end
end
