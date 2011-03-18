module ThreeScale
  module Core
    class Service
      include Storable
      
      attr_accessor :provider_key
      attr_accessor :id
      attr_accessor :backend_version
      attr_writer   :referrer_filters_required
      attr_writer 	:user_registration_required

      def referrer_filters_required?
        @referrer_filters_required
      end
	
      def user_registration_required?
        @user_registration_required
      end
			
      def self.save(attributes = {})
        service = new(attributes)				
        service.save
        service
      end
      
      def save
        storage.set(id_storage_key, id)
        storage.set(storage_key(:referrer_filters_required), referrer_filters_required? ? 1 : 0)
        storage.set(storage_key(:user_registration_required), user_registration_required? ? 1 : 0)
        storage.set(storage_key(:backend_version), @backend_version) if @backend_version
      end
      
      def self.load(provider_key)
        id = storage.get(id_storage_key(provider_key))
        id and begin
                 referrer_filters_required, backend_version, user_registration_required = storage.mget(storage_key(id, :referrer_filters_required), storage_key(id, :backend_version), storage_key(id, :user_registration_required))
                 referrer_filters_required = referrer_filters_required.to_i > 0
                 user_registration_required = user_registration_required.to_i > 0

                 new(:provider_key              => provider_key,
                     :id                        => id,
                     :referrer_filters_required => referrer_filters_required,
                     :user_registration_required => user_registration_required,
                     :backend_version           => backend_version)
               end
      end

      def self.delete(provider_key)
        storage.del(storage_key(load_id(provider_key), :referrer_filters_required))
        storage.del(storage_key(load_id(provider_key), :user_registration_required))
        storage.del(storage_key(load_id(provider_key), :backend_version))
        storage.del(id_storage_key(provider_key))
      end

      def self.exists?(provider_key)
        storage.exists(id_storage_key(provider_key))
      end
      
      def self.load_id(provider_key)
        storage.get(id_storage_key(provider_key))
      end

      def self.save_id(provider_key, id)
        storage.set(id_storage_key(provider_key), id)
      end
      
      def self.delete_id(provider_key)
        storage.del(id_storage_key(provider_key))
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

      ## ---- add the user dimension. Users are unique on the service scope			
      ## returns true if the user is new
      def user_add(user_id)
        storage.sadd(storage_key(id,":user_set"),user_id)
      end

      ## returns true if the user was removed
      def user_delete(user_id)
        storage.srem(storage_key(id,":user_set"),user_id)
      end
			
      def user_exists?(user_id)
        exists = storage.sismember(storage_key(id,":user_set"),user_id)
      end

      def user_set_size
        storage.scard(storage_key(id,":user_set"))
      end
    end
  end
end
