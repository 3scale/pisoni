module ThreeScale
  module Core
    module APIClient
      module Support
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def status_ok?(method, status)
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
            return @default_uri ||= "/internal/#{self.to_s.split(':').last.downcase!}s" unless uri
            @defalt_uri = uri
          end

          def default_http_error_exception(exception = nil)
            return @default_http_error_exception ||= APIError unless exception
            @default_http_error_exception = exception
          end

          def default_prefix(prefix = nil)
            return @default_prefix ||= self.to_s.split(':').last.downcase.to_sym unless prefix
            @default_prefix = prefix
          end
        end
      end
    end
  end
end
