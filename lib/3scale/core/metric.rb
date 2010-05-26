module ThreeScale
  module Core
    class Metric
      include Storable

      attr_accessor :service_id
      attr_accessor :id
      attr_accessor :parent_id
      attr_accessor :name
      

      def self.save(attributes)
        metrics = new(attributes)
        metrics.save
        metrics
      end

      def save
        storage.set(encode_key("metric/service_id:#{service_id}/name:#{name}/id"), id)
        storage.set(encode_key("metric/service_id:#{service_id}/id:#{id}/name"), name)
        storage.set(encode_key("metric/service_id:#{service_id}/id:#{id}/parent_id"), parent_id) if parent_id

        storage.sadd(encode_key("metrics/service_id:#{service_id}/ids"), id)

        save_children
      end

      def children
        @children ||= []
      end

      attr_writer :children

      private

      def save_children
        children.each do |child|
          child.service_id = service_id
          child.parent_id  = id
          child.save
        end
      end
    end
  end
end
