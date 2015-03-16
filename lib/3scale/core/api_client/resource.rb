module ThreeScale
  module Core
    module APIClient
      Error = Class.new StandardError

      class APIError < Error
        attr_reader :method, :uri, :response, :attributes

        def initialize(method, uri, response, attributes)
          @method, @uri, @response, @attributes = method, uri, response, attributes
          super "#{self.class}: #{response.status} #{method.upcase} #{uri}, attributes:" \
            " #{attributes.inspect}, response.body: #{response.body[0,256]}"
        end
      end

      class APIServerError < APIError
        def initialize(method, uri, response, attributes = {})
          super
        end
      end

      APIInternalServerError = Class.new APIServerError
      APIBadGatewayError = Class.new APIServerError
      APIServiceUnavailableError = Class.new APIServerError

      class ConnectionError < Error
        def initialize(error)
          super "#{self.class}: #{error.message}"
        end
      end

      class JSONError < Error
        def initialize(error)
          msg = error.respond_to?(:message) ? error.message : error
          super "#{self.class}: #{msg[0,512]}"
        end
      end

      class Resource

        include Attributes
        include Support
        include Operations

        def initialize(attributes)
          update_attributes(attributes)
        end

      end
    end
  end
end
