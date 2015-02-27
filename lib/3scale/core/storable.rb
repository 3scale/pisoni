module ThreeScale
  module Core
    # Mix this into objects that should be storable in the storage.
    module Storable
      def self.included(base)
        base.extend(ClassMethods)
      end

      def initialize(attributes = {})
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end

      def storage
        self.class.storage
      end

      module ClassMethods
        def storage
          Core.storage
        end
      end
    end
  end
end
