require 'erb'

module ThreeScale
  module Core
    module APIClient
      module Support
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def status_ok?(method, uri, response)
            status = response.status
            # handle server errors here, since we will not be expecting JSON
            raise internal_api_error(status).new(method, uri, response) if status >= 500
            case method
              when :post then [200, 201]
              when :put then [200, 204, 202]
              when :delete then [200, 204, 202]
              else [200]
            end.include? status
          end

          def parse_json(body)
            JSON.parse(body, symbolize_names: true)
          end

          def default_uri(uri = nil)
            return @default_uri ||= "/internal/#{self.to_s.split(':').last.downcase!}s/" unless uri
            @default_uri = uri
          end

          def default_http_error_exception(exception = nil)
            return @default_http_error_exception ||= APIError unless exception
            @default_http_error_exception = exception
          end

          def default_prefix(prefix = nil)
            return @default_prefix ||= self.to_s.split(':').last.downcase.to_sym unless prefix
            @default_prefix = prefix
          end

          def url_encode(str)
            ERB::Util.url_encode(str)
          end

          private

          def internal_api_error(status)
            case status
              when 503 then APIServiceUnavailableError
              when 502 then APIBadGatewayError
              when 500 then APIInternalServerError
              else APIServerError
            end
          end
        end
      end
    end
  end
end
