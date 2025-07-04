# config/application.rb

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Alpha
  class Application < Rails::Application
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    # Settings in config/environments/* take precedence over those specified here.
    config.api_only = true
  end
end
