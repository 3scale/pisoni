module ThreeScale
  module Core
    class Service
      include Storable

      def self.save(attributes = {})
        storage.set(key(attributes[:provider_key]), attributes[:id])
      end

      def self.load_id(provider_key)
        storage.get(key(provider_key))
      end

      def self.delete(provider_key)
        storage.del(key(provider_key))
      end

      def self.exists?(provider_key)
        storage.exists(key(provider_key))
      end

      def self.key(provider_key)
        encode_key("service/provider_key:#{provider_key}/id")
      end
    end
  end
end
