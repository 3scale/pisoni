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

      class ConnectionError < Error
        def initialize(error)
          super "#{self.class}: #{error.message}"
        end
      end

      JSONError = Class.new Error

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
