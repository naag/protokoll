require 'protokoll/main'
require 'protokoll/log_subscriber/action_view'
require 'protokoll/log_subscriber/action_controller'
require 'protokoll/log_subscriber/active_record'

module Protokoll
  def self.remove_existing_log_subscriptions
    ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
      case subscriber
      when ActionView::LogSubscriber
        unsubscribe(:action_view, subscriber)
      when ActionController::LogSubscriber
        unsubscribe(:action_controller, subscriber)
      when ActiveRecord::LogSubscriber
        unsubscribe(:active_record, subscriber)
      end
    end
  end

  def self.unsubscribe(component, subscriber)
    events = subscriber.public_methods(false).reject { |method| method.to_s == 'call' }
    events.each do |event|
      ActiveSupport::Notifications.notifier.listeners_for("#{event}.#{component}").each do |listener|
        if listener.instance_variable_get('@delegate') == subscriber
          ActiveSupport::Notifications.unsubscribe listener
        end
      end
    end
  end

  def self.disable_default_logging
    remove_existing_log_subscriptions
    require 'protokoll/rails_ext/rack/logger'
  end

  def self.setup(app)
    app.config.colorize_logging = false
    disable_default_logging

    Rails.logger.formatter = proc do |severity, _datetime, _progname, msg|
      "#{format_message(severity, msg)}\n"
    end
  end

  def self.format_message(severity, msg)
    params = {
      severity: severity.downcase,
      message: msg
    }
    add_request_data(params)
    LogStash::Event.new(params).to_json
  end

  def self.add_request_data(params)
    params[:client] = Thread.current[client_var] if Thread.current[client_var]
    params[:request_id] = Thread.current[request_id_var] if Thread.current[request_id_var]
    params
  end

  def self.client_var
    Rails.application.config.protokoll.client
  end

  def self.request_id_var
    Rails.application.config.protokoll.request_id
  end
end

require 'protokoll/railtie' if defined?(Rails)
