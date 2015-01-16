module Protokoll
  module Middleware
    class Logging < ActionDispatch::RemoteIp
      def initialize(app)
        @app = app
      end

      def call(env)
        Thread.current[client_var] = env["action_dispatch.remote_ip"].to_s
        Thread.current[request_id_var] = env["action_dispatch.request_id"].to_s

        start = Time.now
        @result = @app.call(env)
        finish = Time.now

        return @result unless valid_response
        @request = ActionDispatch::Request.new(env)

        log_data = {
          message: "Completed request for #{@request.fullpath} with status #{status_code}",
          status: status_code,
          params: fix_utf8(params),
          method: @request.request_method,
          url: @request.fullpath,
          routing_info: routing_info,
          duration: ((finish - start) * 1000).to_i,
          user_agent: @request.user_agent
        }
        log_data[:raw_request_body] = fix_utf8(@request.raw_post) if status_code > 299

        Rails.logger.send(log_level.to_sym, log_data)
        @result
      end

      private

      def log_level
        case status_code
        when 200..399 then :info
        when 400..499 then :warn
        else :error
        end
      end

      def valid_response
        @result.is_a?(Array) && @result.length == 3
      end

      def status_code
        @result[0]
      end

      def params
        @request.params.reject do |k, _|
          %w(controller action format).include? k
        end
      end

      def routing_info
        {
          controller: @request.params["controller"],
          action: @request.params["action"],
          format: @request.params["format"]
        }
      end

      def fix_utf8(object)
        if object.instance_of? String
          object.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
        elsif object.instance_of? Hash
          result = {}
          object.each do |k, v|
            result[k] = fix_utf8(v)
          end
          result
        elsif object.instance_of? Array
          result = []
          object.each do |v|
            result << fix_utf8(v)
          end
          result
        else
          object
        end
      end

      def client_var
        Rails.application.config.protokoll.client
      end

      def request_id_var
        Rails.application.config.protokoll.request_id
      end
    end
  end
end
