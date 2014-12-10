module ThreeScale
  module Core
    module APIClient
      class APIError < StandardError
        attr_reader :method, :uri, :response, :attributes

        def initialize(method, uri, response, attributes)
          @method, @uri, @response, @attributes = method, uri, response, attributes
          super "Error #{response.status} #{method.upcase} #{uri}, attributes:" \
            " #{attributes.inspect}, response.body: #{response.body.inspect}"
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
