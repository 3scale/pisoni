module ThreeScale
  module Core
    class Contract
      include Storable
      
      attr_accessor :service_id
      attr_accessor :user_key

      attr_accessor :id
      attr_accessor :state
      attr_accessor :plan_id
      attr_accessor :plan_name

      def self.load(service_id, user_key)
        values = storage.mget(key(service_id, user_key, :id),
                              key(service_id, user_key, :state),
                              key(service_id, user_key, :plan_id),
                              key(service_id, user_key, :plan_name))
        id, state, plan_id, plan_name = values

        id && new(:service_id => service_id,
                  :user_key   => user_key,
                  :id         => id,
                  :state      => state.to_sym,
                  :plan_id    => plan_id,
                  :plan_name  => plan_name)
      end

      def self.delete(service_id, user_key)
        storage.del(key(service_id, user_key, :id))
        storage.del(key(service_id, user_key, :state))
        storage.del(key(service_id, user_key, :plan_id))
        storage.del(key(service_id, user_key, :plan_name))
      end

      def self.save(attributes)
        contract = new(attributes)
        contract.save
      end

      def save
        storage.set(key(service_id, user_key, :id), id)
        storage.set(key(service_id, user_key, :state), state.to_s)    if state
        storage.set(key(service_id, user_key, :plan_id), plan_id)     if plan_id
        storage.set(key(service_id, user_key, :plan_name), plan_name) if plan_name
      end

      def self.key(service_id, user_key, attribute)
        encode_key("contract/service_id:#{service_id}/user_key:#{user_key}/#{attribute}")
      end

      def key(service_id, user_key, attributes)
        self.class.key(service_id, user_key, attributes)
      end
    end
  end
end
