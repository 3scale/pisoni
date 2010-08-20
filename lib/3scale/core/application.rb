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
        values = storage.mget(storage_key(service_id, id, :state),
                              storage_key(service_id, id, :plan_id),
                              storage_key(service_id, id, :plan_name))
        state, plan_id, plan_name = values

        state and new(:service_id => service_id,
                      :id         => id,
                      :state      => state.to_sym,
                      :plan_id    => plan_id,
                      :plan_name  => plan_name)
      end

      def self.delete(service_id, id)
        storage.del(storage_key(service_id, id, :state))
        storage.del(storage_key(service_id, id, :plan_id))
        storage.del(storage_key(service_id, id, :plan_name))
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
        storage.set(storage_key(service_id, id, :state), state.to_s)    if state
        storage.set(storage_key(service_id, id, :plan_id), plan_id)     if plan_id
        storage.set(storage_key(service_id, id, :plan_name), plan_name) if plan_name
      end

      def self.storage_key(service_id, id, attribute)
        encode_key("application/service_id:#{service_id}/id:#{id}/#{attribute}")
      end

      def storage_key(service_id, id, attribute)
        self.class.storage_key(service_id, id, attribute)
      end
    end
  end
end
