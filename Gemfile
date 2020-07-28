source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4.2'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem "sassc-rails", "~> 2.1.0"
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'


# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
gem 'capistrano-rails', group: :development
gem 'capistrano3-puma', group: :development
gem 'capistrano-delayed-job', '~> 1.0', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # OR call 'binding.pry' which gets you an even better pry console with stepping and stack navigation
  gem 'pry-byebug'
  # Use sqlite3 as the database for Active Record - problems using 1.4 with rails 5.2.2, should be fixed in 5.2.3
  gem 'sqlite3', '~> 1.3', '< 1.4'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Guard for autotesting and ctags
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-ctags-bundler'
end


# ===========================
# Gems specific to hedonometer
# ===========================

gem "rails-controller-testing", "~> 1.0"

gem 'haml', '~> 5.0.4'
gem 'bootstrap', '~> 4.3.1'

gem 'twilio-ruby', '~> 3.9.0'

gem 'jquery-rails', '4.3.3'
gem 'json', '~> 2.3.0'

gem 'daemons', '~> 1.1.9'
gem 'delayed_job', '~> 4.1.5'
gem 'delayed_job_active_record', '~> 4.1.3'

gem 'aasm', '~> 3.0.20'

group :production do
  # Use postgres as the database for Active Record in production
  gem 'pg', '~> 0.18.1'
end


gem "webmock", "~> 3.5"
