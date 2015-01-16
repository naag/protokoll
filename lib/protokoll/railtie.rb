require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'

module Protokoll
  class Railtie < Rails::Railtie
    config.protokoll = ActiveSupport::OrderedOptions.new
    config.protokoll.enabled = true
    config.protokoll.client = :client_ip
    config.protokoll.request_id = :request_id

    # C.f. http://guides.rubyonrails.org/configuring.html
    initializer 'protokoll.configure_logger', before: 'initialize_logger' do |app|
      Rails.logger = Logger.new(STDOUT)
    end

    initializer :protokoll, after: 'protokoll.configure_logger' do |app|
      Protokoll.setup(app) if app.config.protokoll.enabled
    end
  end
end
