module ThreeScale
  module Core
    class Application
      include Storable
      
      attr_accessor :service_id
      attr_accessor :id
      attr_accessor :state
      ## plan should be an object, in the meantime this will do
      attr_accessor :plan_id
      attr_accessor :plan_name
      attr_accessor :redirect_url

      ## added the :user_required to distinguish between types of application:
      ## false is the default value, do not expect user_id or ignore it if it happends 
      ## true, the user_id must be defined + the user of the service (service_id#user_id), 
      ## user_id is typically the UUID of a cellphone, or the twitter account
      attr_accessor :user_required
      attr_accessor :version

      def self.load(service_id, id)
        values = storage.mget(storage_key(service_id, id, :state),
                              storage_key(service_id, id, :plan_id),
                              storage_key(service_id, id, :plan_name),
                              storage_key(service_id, id, :user_required),
                              storage_key(service_id, id, :redirect_url),
                              storage_key(service_id, id, :version))
        state, plan_id, plan_name, user_required, redirect_url, version = values

        ## the default value is false
        user_required = user_required.to_i > 0

        state and new(:service_id => service_id,
                      :id         => id,
                      :state      => state.to_sym,
                      :plan_id    => plan_id,
                      :plan_name  => plan_name,
                      :user_required => user_required,
                      :redirect_url => redirect_url,
                      :version => version)
      end

      def user_required?
        @user_required
      end

      def self.delete(service_id, id)
        storage.del(storage_key(service_id, id, :state))
        storage.del(storage_key(service_id, id, :plan_id))
        storage.del(storage_key(service_id, id, :plan_name))
        storage.del(storage_key(service_id, id, :user_required))
        storage.del(storage_key(service_id, id, :redirect_url))
        storage.del(storage_key(service_id, id, :version))
      end

      def self.get_version(service_id, id)
        storage.get(storage_key(service_id, id, :version))
      end

      def self.incr_version(service_id, id)
        storage.incrby(storage_key(:version),1)
      end


      def self.save(attributes)
        application = new(attributes)
        application.save
        application
      end

      def self.exists?(service_id, id)
        storage.exists(storage_key(service_id, id, :state))
      end

      def save
        storage.set(storage_key(:state), state.to_s)    if state
        storage.set(storage_key(:plan_id), plan_id)     if plan_id
        storage.set(storage_key(:plan_name), plan_name) if plan_name
        storage.set(storage_key(:user_required), user_required? ? 1 : 0)
        storage.set(storage_key(:redirect_url), redirect_url) if redirect_url
        storage.incrby(storage_key(:version),1)
      end

      def self.storage_key(service_id, id, attribute)
        encode_key("application/service_id:#{service_id}/id:#{id}/#{attribute}")
      end

      def storage_key(attribute)
        self.class.storage_key(service_id, id, attribute)
      end

      # XXX: Old API compatibility methods.

      def self.save_id_by_key(service_id, key, id)
        storage.set(id_by_key_storage_key(service_id, key), id)
      end

      def self.load_id_by_key(service_id, key)
        storage.get(id_by_key_storage_key(service_id, key))
      end

      def self.delete_id_by_key(service_id, key)
        storage.del(id_by_key_storage_key(service_id, key))
      end

      def self.id_by_key_storage_key(service_id, key)
        encode_key("application/service_id:#{service_id}/key:#{key}/id")
      end
    end
  end
end
