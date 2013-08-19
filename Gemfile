source 'https://rubygems.org'

gem 'rails', '~> 4.0.0'
gem 'haml', '~> 4.0.0'

gem 'twilio-ruby', '~> 3.9.0'

gem 'jquery-rails'
gem 'json', '~> 1.7.7'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0', require: 'bcrypt'

gem 'daemons'
gem 'delayed_job'
gem 'delayed_job_active_record'

gem 'aasm', '~> 3.0.20'


group :development do
  gem 'capistrano'
  gem 'mysql2', '~> 0.3.11'

  # Testing stuff
  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false
  gem 'guard'
  gem 'guard-minitest', git: 'git://github.com/guard/guard-minitest.git'
  gem 'spring', git: 'git://github.com/jonleighton/spring.git'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'pry-debugger'
  gem 'uglifier', '>= 1.0.3'
  gem 'webmock', '~> 1.13.0'

  # Gems used only for assets and not required
  gem 'sass', '~> 3.2.8'
  gem 'sass-rails', '~> 4.0.0'
  gem 'compass', '~> 0.12.2'
  gem 'compass-rails', '~> 2.0.alpha.0'

  gem 'susy', '~> 1.0.5'
  gem 'coffee-rails', '~> 4.0.0'

end


group :production do
  gem 'sqlite3'
  gem 'unicorn'
end
