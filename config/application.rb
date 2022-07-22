require_relative 'boot'

require 'rails/all'
require_relative '../app/models/time_range.rb'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hedonometer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # For dev mode, use integers for booleans in sqlite is recommended
    config.active_record.sqlite3.represent_boolean_as_integer = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # ActiveJob should use delayed_job
    config.active_job.queue_adapter = :delayed_job

    # We need to be able to serialize TimeRange
    # See https://stackoverflow.com/questions/72970170/upgrading-to-rails-6-1-6-1-causes-psychdisallowedclass-tried-to-load-unspecif
    config.active_record.yaml_column_permitted_classes = [TimeRange, Time]
  end
end
