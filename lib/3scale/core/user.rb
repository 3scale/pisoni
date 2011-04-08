module ThreeScale
  module Core
    class User
      include Storable
      
      attr_accessor :service_id
      attr_accessor :username
      attr_accessor :state
      attr_accessor :plan_id
      attr_accessor :plan_name
      attr_accessor :version
      
      def self.load(service, username)
        
        key = self.key(service.id, username)

        values = storage.hmget(key,"state","plan_id","plan_name")
        state, plan_id, plan_name = values

        user = nil

        if state.nil? ## the user does not exist
          return nil if service.user_registration_required?
          ## the user did not exist and we need to create it

          user = new(:service_id => service.id,
                     :username   => username,
                     :state      => :active.to_sym,
                     :plan_id    => service.default_user_plan_id,
                     :plan_name  => service.default_user_plan_name) 
          user.save
        else 
          user = new(:service_id => service.id,
                          :username   => username,
                          :state      => state.to_sym,
                          :plan_id    => plan_id,
                          :plan_name  => plan_name)
        end

        return user
      end

      def self.save(attributes)
        user = new(attributes)
        user.save
        user
      end

      def save  

        storage.hset(key,"state", state.to_s) if state
        storage.hset(key,"plan_id", plan_id)     if plan_id
        storage.hset(key,"plan_name", plan_name) if plan_name
        storage.hset(key,"username", username) if username
        storage.hset(key,"service_id", service_id) if service_id
        storage.incrby(storage_key(service_id, username, :version),1)
        
        Service.incr_version(service_id)
      end

      def self.get_version(service_id, username)
        storage.get(storage_key(service_id, username,:version))
      end

      def self.incr_version(service_id, username)
        storage.incrby(storage_key(service_id, username,:version),1)
      end

      def self.delete(service_id, username)
        key = self.key(service_id, username)
        storage.hdel(key,"state")
        storage.hdel(key,"plan_id")
        storage.hdel(key,"plan_name")
        storage.hdel(key,"username")
        storage.hdel(key,"service_id")
        storage.del(storage_key(service_id, username,:version))

        Service.incr_version(service_id)
      end
      
      def active?
        state == :active
      end

      def key
          self.class.key(service_id,username)
      end

      def self.key(service_id, username)
         "service:#{service_id}/user:#{username}"
      end

      def storage_key(service_id, username, attribute)
         self.class.storage_key(service_id, username, attribute)
      end

      def self.storage_key(service_id, username, attribute)
         "service:#{service_id}/user:#{username}/#{attribute}"
      end

    end
  end
end
