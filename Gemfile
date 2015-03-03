source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'
gem 'haml', '~> 4.0.0'

gem 'twilio-ruby', '~> 3.9.0'

gem 'jquery-rails', '3.0.4'
gem 'json', '~> 1.8.2'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0', require: 'bcrypt'

gem 'daemons', '~> 1.1.9'
gem 'delayed_job', '~> 4.0.0'
gem 'delayed_job_active_record', :git => 'git@github.com:panter/delayed_job_active_record.git'

gem 'aasm', '~> 3.0.20'

group :development do
  gem 'web-console', '~> 2.0'
  gem 'capistrano', '~> 2.15.5'
  gem 'mysql2', '~> 0.3.11'
  gem 'ffi', '<1.9.3'
  gem 'spring', '~> 1.2.0'
  gem 'webmock', '~> 1.13.0'

  # Gems used only for assets and not required in production
  gem 'sass', '~> 3.4.13'
  gem 'sass-rails', '~> 5.0.0'
  gem 'compass', '~> 1.0.3'
  gem 'compass-rails', '2.0.4'
  gem 'uglifier', '>= 2.7.1'
  gem 'susy', '~> 2.2.2'
  gem 'coffee-rails', '~> 4.1.0'
end


group :production do
  gem 'pg', '~> 0.18.1'
  gem 'unicorn'
end
