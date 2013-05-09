source 'https://rubygems.org'

gem 'rails', git: 'https://github.com/rails/rails.git', tag: 'v4.0.0.rc1'
gem 'haml', '~> 4.0.0'

gem 'twilio-ruby', '~> 3.9.0'

gem 'jquery-rails'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0', require: 'bcrypt'


group :development do
  gem 'capistrano'
  gem 'mysql2', '~> 0.3.11'

  # Testing stuff
  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false
  gem 'guard'
  gem 'guard-test'
  gem 'spring', git: 'git://github.com/jonleighton/spring.git'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'pry-debugger'
  gem 'uglifier', '>= 1.0.3'

  # Gems used only for assets and not required
  gem 'sass', '~> 3.2.8'
  gem 'sass-rails', git: 'git://github.com/rails/sass-rails.git'
  gem 'compass', '~> 0.12.2'
  gem 'compass-rails', git: 'git://github.com/Compass/compass-rails.git', tag: 'rails4'
  gem 'susy', '~> 1.0.5'
  gem 'coffee-rails', '~> 4.0.0'

end


group :production do
  gem 'sqlite3'
  gem 'unicorn'
end
