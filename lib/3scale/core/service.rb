module ThreeScale
  module Core
    class Service
      include Storable

      ATTRIBUTES = %w(provider_key id backend_version referrer_filters_required
        user_registration_required default_user_plan_id default_user_plan_name
        version default_service)

      attr_accessor *(ATTRIBUTES.map { |attr| attr.to_sym })

      def default_service?
        @default_service
      end

      def referrer_filters_required?
        @referrer_filters_required
      end

      def user_registration_required?
        @user_registration_required
      end

      def self.save!(attributes = {})
        if attributes[:user_registration_required].nil?
          val = storage.get(storage_key(attributes[:id], :user_registration_required))
          if !val.nil? && val.to_i==0
            ## the attribute already existed and was set to false, BEWARE of that if a
            ## service already existed and was set to false, that's somewhat problematic
            ## on the tests
            attributes[:user_registration_required]=false
          else
            attributes[:user_registration_required]=true
          end
        end
        service = new(attributes)
        service.save!
        service
      end

      ## only save as default if it's the first one (load_id returns null)
      def save!
        if !user_registration_required? && (default_user_plan_id.nil? || default_user_plan_name.nil?)
          raise ServiceRequiresDefaultUserPlan
        end

        default_service_id = self.class.load_id(provider_key)
        @default_service = default_service_id.nil? || default_service_id==id

        storage.multi do
          storage.set(id_storage_key, id) if default_service?
          storage.sadd(id_storage_key_set,id)
          storage.set(storage_key(:referrer_filters_required), referrer_filters_required? ? 1 : 0)
          storage.set(storage_key(:user_registration_required), user_registration_required? ? 1 : 0)
          storage.set(storage_key(:default_user_plan_id),default_user_plan_id) unless default_user_plan_id.nil?
          storage.set(storage_key(:default_user_plan_name),default_user_plan_name) unless default_user_plan_name.nil?
          storage.set(storage_key(:backend_version), @backend_version) if @backend_version
          storage.set(storage_key(:provider_key), provider_key)
          storage.incrby(storage_key(:version), 1)
          storage.sadd(services_set_key,id)
          storage.sadd(provider_keys_set_key,provider_key)
        end
      end

      ## returns the old default service id
      def make_default_service
        if !default_service?
          default_service_id = self.class.load_id(provider_key)
          storage.multi do
            storage.set(id_storage_key, id)
            self.class.incr_version(default_service_id)
            self.class.incr_version(id)
          end
          return default_service_id
        else
          return id
        end
      end

      def self.load_by_id(service_id)
        response = Core.faraday.get "services/#{service_id}"
        service = JSON.parse(response.body)

        attributes = {}
        ATTRIBUTES.each { |attr| attributes[attr] = service[attr] }
        new attributes
      end

      def self.delete_by_id!(service_id, options = {})
        response = Core.faraday.delete "services/#{service_id}", options

        if response.status != 200
          raise ServiceIsDefaultService, service_id if response.status == 400
          raise "Error deleting a Service, response code: #{response.satus},
            response body: #{response.body.inspect}"
        end
        return true
      end

      def self.list(provider_key)
        response = Core.faraday.get "services/?provider_key=#{provider_key}"

        JSON.parse(response.body)
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

      def self.id_storage_key_set(provider_key)
        encode_key("service/provider_key:#{provider_key}/ids")
      end

      def id_storage_key_set
        self.class.id_storage_key_set(provider_key)
      end

      def services_set_key
        self.class.services_set_key
      end

      def provider_keys_set_key
        self.class.provider_keys_set_key
      end

      def self.services_set_key
        encode_key("services_set")
      end

      def self.provider_keys_set_key
        encode_key("provider_keys_set")
      end

      ## ---- add the user dimension. Users are unique on the service scope
      ## returns true if the user is new
      def user_add(username)
        isnew = storage.sadd(storage_key("user_set"),username)
        self.class.incr_version(id)
        return isnew
      end

      def user_delete(username)
        storage.srem(storage_key("user_set"),username)
        self.class.incr_version(id)
      end

      def user_exists?(username)
        exists = storage.sismember(storage_key("user_set"),username)
      end

      def user_size
        storage.scard(storage_key("user_set"))
      end

      ## method to change the provider key for a costumer,
      def self.change_provider_key!(old_provider_key, new_provider_key)
        raise InvalidProviderKeys if old_provider_key.nil? || new_provider_key.nil? || new_provider_key == "" || old_provider_key==new_provider_key
        raise ProviderKeyExists, new_provider_key unless Service.list(new_provider_key).size==0

        services_list_id = Service.list(old_provider_key)
        raise ProviderKeyNotFound, old_provider_key if services_list_id.nil? or services_list_id.size==0

        default_service_id = Service.load_id(old_provider_key)
        services_list_id.delete(default_service_id)

        storage.multi do
          services_list_id.each do |service_id|
            storage.sadd(id_storage_key_set(new_provider_key),service_id)
            storage.set(storage_key(service_id, :provider_key),new_provider_key)
            storage.incrby(storage_key(service_id,:version),1)
          end

          storage.set(id_storage_key(new_provider_key), default_service_id)
          storage.sadd(id_storage_key_set(new_provider_key), default_service_id)
          storage.set(storage_key(default_service_id, :provider_key),new_provider_key)
          storage.del(id_storage_key(old_provider_key))
          storage.del(id_storage_key_set(old_provider_key))
          storage.incrby(storage_key(default_service_id,:version),1)
        end
      end
    end
  end
end
