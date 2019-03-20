# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require "capistrano/rails"
#require 'capistrano/delayed_job'
require 'capistrano/puma'
install_plugin Capistrano::Puma

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

set :application, "h2"
set :repo_url, "git@github.com:uwmadison-chm/hedonometer.git"

#set :pty, true

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'
append :linked_files, 'config/database.yml', 'config/secrets.yml', 'public/.htaccess'

set :puma_init_active_record, true

namespace :delayed_job do
  desc "start delayed_job"
  task :start do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :nohup, 'bin/rake jobs:work > /dev/null 2>&1 &'
        end
      end
    end
  end

  desc "stop delayed_job"
  task :stop do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          # Yeah, uhh, this almost definitely isn't the best way to do this
          execute :killall, '-q -9 -w bin/rake jobs:work; true'
        end
      end
    end
  end

  desc "restart delayed_job"
  task :restart do
    invoke 'delayed_job:stop'
    invoke 'delayed_job:start'
  end
end
