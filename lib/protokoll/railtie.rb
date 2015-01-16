require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'

module Protokoll
  class Railtie < Rails::Railtie
    config.logger = Logger.new(STDOUT)
    config.protokoll = ActiveSupport::OrderedOptions.new
    config.protokoll.enabled = true
    config.protokoll.client = :client_ip
    config.protokoll.request_id = :request_id

    initializer :protokoll do |app|
      Protokoll.setup(app) if app.config.protokoll.enabled
    end
  end
end
