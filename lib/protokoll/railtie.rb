require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'

module Protokoll
  class Railtie < Rails::Railtie
    config.protokoll = ActiveSupport::OrderedOptions.new
    config.protokoll.enabled = false

    initializer :protokoll do |app|
      Protokoll.setup(app) if app.config.protokoll.enabled
    end
  end
end
