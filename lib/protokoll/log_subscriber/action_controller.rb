module Protokoll
  module LogSubscriber
    class ActionController < ActiveSupport::LogSubscriber
      def process_action(event)
        params = event.payload[:params].reject do |k, _|
          %w(format action controller).include? k
        end

        log = {
          time: event.time,
          end: event.end,
          message: event.name,
          transaction_id: event.transaction_id,
          controller: event.payload[:controller],
          action: event.payload[:action],
          format: event.payload[:format],
          method: event.payload[:method],
          path: event.payload[:path],
          status: event.payload[:status],
          view_runtime: event.payload[:view_runtime],
          db_runtime: event.payload[:db_runtime],
          params: params
        }

        logger.info(log.to_json)
      end
    end
  end
end
