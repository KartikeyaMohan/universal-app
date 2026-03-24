require_relative "boot"

require "rails/all"

require "/shared/jwt_auth/authenticatable"

Bundler.require(*Rails.groups)

module UserService
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
  end
end
