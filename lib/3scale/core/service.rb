module ThreeScale
  module Core
    class Service
      include Storable
      
      attr_accessor :provider_key
      attr_accessor :id
      attr_accessor :backend_version
      attr_writer   :referrer_filters_required
      attr_writer 	:user_registration_required
      attr_accessor :default_user_plan_id
      attr_accessor :default_user_plan_name
      attr_writer   :version


      def referrer_filters_required?
        @referrer_filters_required
      end
	
      def user_registration_required?
        @user_registration_required
      end
			
      def self.save(attributes = {})
        attributes[:user_registration_required]=true if attributes[:user_registration_required].nil?
        service = new(attributes)				
        service.save
        service
      end
      
      def save
        if !user_registration_required? && (default_user_plan_id.nil? || default_user_plan_name.nil?) 
          raise 'Services with users open loop for users requires a default plan for them'
        end
  
        storage.set(id_storage_key, id)
        storage.set(storage_key(:referrer_filters_required), referrer_filters_required? ? 1 : 0)
        storage.set(storage_key(:user_registration_required), user_registration_required? ? 1 : 0)
        storage.set(storage_key(:default_user_plan_id),default_user_plan_id) unless default_user_plan_id.nil?
        storage.set(storage_key(:default_user_plan_name),default_user_plan_name) unless default_user_plan_name.nil?
        storage.set(storage_key(:backend_version), @backend_version) if @backend_version
        storage.set(storage_key(:provider_key), provider_key)
        storage.incrby(storage_key(:version), 1)
      end
      
      def self.load_by_id(service_id)
        id = service_id
        id and begin
                 values  = storage.mget(storage_key(id, :referrer_filters_required), storage_key(id, :backend_version), storage_key(id, :user_registration_required), storage_key(id,:default_user_plan_id), storage_key(id,:default_user_plan_name),storage_key(id,:provider_key), storage_key(id,:version))

                referrer_filters_required, backend_version, user_registration_required, default_user_plan_id, default_user_plan_name, provider_key, vv = values

                 ## warning, not sure this is very elegant
                return nil if provider_key.nil?
                referrer_filters_required = referrer_filters_required.to_i > 0

                 ## the default is true, because it's more restrictive, nil.to_i == 0
                if user_registration_required.nil?
                  user_registration_required = true
                else                           
                  user_registration_required = user_registration_required.to_i > 0
                end                

                self.incr_version(id) if vv.nil?


                  new(:provider_key              => provider_key,
                     :id                        => id,
                     :referrer_filters_required => referrer_filters_required,
                     :user_registration_required => user_registration_required,
                     :backend_version           => backend_version,
                     :default_user_plan_id      => default_user_plan_id,
                     :default_user_plan_name    => default_user_plan_name,
                     :version                   => self.get_version(id))

                end
      end

      def self.load(provider_key)
        id = storage.get(id_storage_key(provider_key))
        id and begin
                 values = storage.mget(storage_key(id, :referrer_filters_required), storage_key(id, :backend_version), storage_key(id, :user_registration_required), storage_key(id,:default_user_plan_id), storage_key(id,:default_user_plan_name),storage_key(id,:version))
                 referrer_filters_required, backend_version, user_registration_required, default_user_plan_id, default_user_plan_name, vv = values

                 referrer_filters_required = referrer_filters_required.to_i > 0
                 user_registration_required = user_registration_required.to_i > 0
                 self.incr_version(id) if vv.nil?


                 new(:provider_key              => provider_key,
                     :id                        => id,
                     :referrer_filters_required => referrer_filters_required,
                     :user_registration_required => user_registration_required,
                     :backend_version           => backend_version,
                     :default_user_plan_id      => default_user_plan_id,
                     :default_user_plan_name    => default_user_plan_name,
                     :version                   => self.get_version(id))

               end
      end

      def self.delete(provider_key)
        storage.del(storage_key(load_id(provider_key), :referrer_filters_required))
        storage.del(storage_key(load_id(provider_key), :user_registration_required))
        storage.del(storage_key(load_id(provider_key), :backend_version))
        storage.del(storage_key(load_id(provider_key), :default_user_plan_name))
        storage.del(storage_key(load_id(provider_key), :default_user_plan_id))
        storage.del(storage_key(load_id(provider_key), :provider_key))
        storage.del(storage_key(load_id(provider_key), :version))
        storage.del(storage_key(load_id(provider_key), :user_set))
        storage.del(id_storage_key(provider_key))
      end

      def self.get_version(id)
        storage.get(storage_key(id, :version))
      end

      def self.incr_version(id)
        storage.incrby(storage_key(id,:version),1)
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
      def user_add(username)
        isnew = storage.sadd(storage_key(id,":user_set"),username)
        self.class.incr_version(id)
        return isnew
      end

      def user_delete(username)
        storage.srem(storage_key(id,":user_set"),username)
        self.class.incr_version(id)
      end
			
      def user_exists?(user_id)
        exists = storage.sismember(storage_key(id,":user_set"),username)
      end

      def user_set_size
        storage.scard(storage_key(id,":user_set"))
      end
    end
  end
end
