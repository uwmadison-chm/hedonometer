source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'haml', '~> 4.0.0'

gem 'twilio-ruby', '~> 3.9.0'

group :development do
  gem 'capistrano'
  gem 'mysql2', '~> 0.3.11'

  # Testing stuff
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'guard'
  gem 'guard-test'
  gem 'spring', :git => 'git://github.com/jonleighton/spring.git'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'pry-debugger'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0', :require => 'bcrypt'

gem 'strong_parameters'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass', '~> 3.2.5'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'compass', '~> 0.12.2'
  gem 'compass-rails', '~> 1.0.3'
  gem 'susy', '~> 1.0.5'
  gem 'coffee-rails', '~> 3.2.2'
end

group :production do
  gem 'sqlite3'
  gem 'unicorn'
end
