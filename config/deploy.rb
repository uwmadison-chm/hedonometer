# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :ruby_version, '/var/www/apps/h2/shared/ruby/2.6.1/bin'

set :application, "h2"
set :deploy_to, "/var/www/apps/h2"
set :default_env, { path: "#{fetch(:ruby_version)}:$PATH", RAILS_RELATIVE_URL_ROOT: '/h2' }
set :tmp_dir, "/home/sms-sampler/tmp"

