module ThreeScale
  module Core
    class User
      include Storable
      
      attr_accessor :service_id
      attr_accessor :username
      attr_accessor :state
      attr_accessor :plan_id
      attr_accessor :plan_name
      attr_writer   :version
      
      def self.load(service, username)
        
        key = self.key(service.id, username)

        values = storage.hmget(key,"state","plan_id","plan_name","version")
        state, plan_id, plan_name, vv = values

        user = nil
        
        if state.nil? 
          ## the user does not exist yet, we need to create it for the case of the open loop

          if service.user_registration_required?
            raise 'The service does not accept not registered users'
          else
            raise 'The service does not have default user plans' if service.default_user_plan_id || service.default_user_plan_name
            state = "active" if state.nil?
          end
          
          user = new(:service_id => service.id,
                     :username   => username,
                     :state      => state.to_sym,
                     :plan_id    => service.default_user_plan_id,
                     :plan_name  => service.default_user_plan_name) 
          user.save

          Service.incr_version(service.id)

        else 
          user = new(:service_id => service.id,
                          :username   => username,
                          :state      => state.to_sym,
                          :plan_id    => plan_id,
                          :plan_name  => plan_name)
          self.incr_version(service.id, username) if vv.nil?
        end

        return user
      end

      def self.save(attributes)
        raise 'User requires a username' if attributes[:username].nil?        
        raise 'User requires a service id' if attributes[:service_id].nil?
        service = Service.load_by_id(attributes[:service_id])
        raise 'User requires a valid service' if service.nil?
        attributes[:plan_id] ||= service.default_user_plan_id
        attributes[:plan_name] ||= service.default_user_plan_name
        raise 'User requires defined plan' if attributes[:plan_id].nil? || attributes[:plan_name].nil?
        attributes[:state] = "active" if attributes[:state].nil? 
        user = new(attributes)
        user.save
        return user
      end

      def save  
        storage.hset(key,"state", state.to_s) if state
        storage.hset(key,"plan_id", plan_id)     if plan_id
        storage.hset(key,"plan_name", plan_name) if plan_name
        storage.hset(key,"username", username) if username
        storage.hset(key,"service_id", service_id) if service_id
        storage.hincrby(key,"version",1)
      end

      def self.get_version(service_id, username)
        storage.hget(self.key(service_id, username),"version")
      end

      def self.incr_version(service_id, username)
        storage.hincrby(self.key(service_id, username),"version")
      end

      def self.delete(service_id, username)
        storage.del(self.key(service_id, username))
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

      #def storage_key(service_id, username, attribute)
      #   self.class.storage_key(service_id, username, attribute)
      #end

      #def self.storage_key(service_id, username, attribute)
      #   "service:#{service_id}/user:#{username}/#{attribute}"
      #end

    end
  end
end
