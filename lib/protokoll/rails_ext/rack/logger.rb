require 'active_support/log_subscriber'
require 'rails/rack/logger'

module Rails
  module Rack
    class Logger
      def initialize(app, taggers = nil)
        @app          = app
        @taggers      = taggers || []
      end

      def call(env)
        @app.call(env)
      ensure
        ActiveSupport::LogSubscriber.flush_all!
      end
    end
  end
end
