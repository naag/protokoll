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

    logger(app).formatter = proc do |severity, _datetime, _progname, msg|
      "#{format_message(severity, msg)}\n"
    end
  end

  def self.format_message(severity, msg)
    case msg
    when /^\{.*\}$/
      parsed_msg = JSON.parse(msg)
      params = {
        severity: severity.downcase
      }
      params.merge! parsed_msg
      add_request_data(params)
      LogStash::Event.new(params).to_json
    else
      params = {
        severity: severity.downcase,
        message: msg
      }
      add_request_data(params)
      LogStash::Event.new(params).to_json
    end
  end

  def self.add_request_data(params)
    params[:client] = Thread.current[:remote_ip] if Thread.current[:remote_ip]
    params[:request_id] = Thread.current[:request_id] if Thread.current[:request_id]
    params
  end

  def self.logger(app)
    app.config.logger
  end
end

require 'protokoll/railtie' if defined?(Rails)
