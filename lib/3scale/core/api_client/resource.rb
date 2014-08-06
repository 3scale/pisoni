module ThreeScale
  module Core
    module APIClient
      APIError = Class.new(StandardError)

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
