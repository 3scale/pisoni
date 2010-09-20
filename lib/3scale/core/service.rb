module ThreeScale
  module Core
    class Service
      include Storable
      
      attr_accessor :provider_key
      attr_accessor :id
      attr_writer   :referrer_filters_required

      def referrer_filters_required?
        @referrer_filters_required
      end

      def self.save(attributes = {})
        service = new(attributes)
        service.save
        service
      end
      
      def save
        storage.set(id_storage_key, id)
        storage.set(storage_key(:referrer_filters_required), referrer_filters_required? ? 1 : 0)
      end
      
      def self.load(provider_key)
        id = storage.get(id_storage_key(provider_key))
        id and begin
                 referrer_filters_required = storage.get(storage_key(id, :referrer_filters_required))
                 referrer_filters_required = referrer_filters_required.to_i > 0

                 new(:provider_key              => provider_key,
                     :id                        => id,
                     :referrer_filters_required => referrer_filters_required)
               end
      end

      def self.load_id(provider_key)
        storage.get(id_storage_key(provider_key))
      end

      def self.delete(provider_key)
        storage.del(storage_key(load_id(provider_key), :referrer_filters_required))
        storage.del(id_storage_key(provider_key))
      end

      def self.exists?(provider_key)
        storage.exists(id_storage_key(provider_key))
      end

      def self.storage_key(id, attribute)
        encode_key("service/id:#{id}/#{attribute}")
      end

      def storage_key(attribute)
        self.class.storage_key(id, attribute)
      end

      def self.id_storage_key(provider_key)
        encode_key("service/provider_key:#{provider_key}/id")
      end

      def id_storage_key
        self.class.id_storage_key(provider_key)
      end
    end
  end
end
