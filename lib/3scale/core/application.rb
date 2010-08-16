module ThreeScale
  module Core
    class Application
      include Storable
      
      attr_accessor :service_id
      attr_accessor :id
      attr_accessor :state
      attr_accessor :plan_id
      attr_accessor :plan_name

      def self.load(service_id, id)
        values = storage.mget(key(service_id, id, :state),
                              key(service_id, id, :plan_id),
                              key(service_id, id, :plan_name))
        state, plan_id, plan_name = values

        state and new(:service_id => service_id,
                      :id         => id,
                      :state      => state.to_sym,
                      :plan_id    => plan_id,
                      :plan_name  => plan_name)
      end

      def self.delete(service_id, id)
        storage.del(key(service_id, id, :state))
        storage.del(key(service_id, id, :plan_id))
        storage.del(key(service_id, id, :plan_name))
      end

      def self.save(attributes)
        application = new(attributes)
        application.save
      end

      def self.exists?(service_id, id)
        storage.exists(key(service_id, id, :state))
      end

      def save
        storage.set(key(service_id, id, :state), state.to_s)    if state
        storage.set(key(service_id, id, :plan_id), plan_id)     if plan_id
        storage.set(key(service_id, id, :plan_name), plan_name) if plan_name
      end

      def self.key(service_id, id, attribute)
        encode_key("application/service_id:#{service_id}/id:#{id}/#{attribute}")
      end

      def key(service_id, id, attribute)
        self.class.key(service_id, id, attribute)
      end
    end
  end
end
