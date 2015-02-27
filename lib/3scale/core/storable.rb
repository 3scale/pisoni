module ThreeScale
  module Core
    # Mix this into objects that should be storable in the storage.
    module Storable
      def initialize(attributes = {})
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end
    end
  end
end
