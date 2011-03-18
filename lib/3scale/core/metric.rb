module ThreeScale
  module Core
    class Metric
      include Storable

      attr_accessor :service_id
      attr_accessor :id
      attr_accessor :parent_id
      attr_accessor :name

      def self.load_all_ids(service_id)
        storage.smembers(id_set_key(service_id)) || []
      end

      def self.load(service_id, id)
        name, parent_id = storage.mget(key(service_id, id, :name),
                                       key(service_id, id, :parent_id))

        name && new(:id         => id.to_s,
                    :service_id => service_id.to_s,
                    :name       => name,
                    :parent_id  => parent_id)  
      end

      def self.load_all_names(service_id, ids)
        Hash[ids.zip(storage.mget(*ids.map{|id| key(service_id, id, :name)}))]
      end

      def self.load_name(service_id, id)
        storage.get(key(service_id, id, :name))
      end
      
      def self.load_id(service_id, name)
        storage.get(id_key(service_id, name))
      end

      def self.save(attributes)
        metrics = new(attributes)
        metrics.save
        metrics
      end

      def self.delete(service_id, id)
        name = load_name(service_id, id)
       
        storage.del(key(service_id, id, :name))
        storage.del(key(service_id, id, :parent_id))

        storage.del(id_key(service_id, name))
        storage.srem(id_set_key(service_id), id)
      end

      def save
        storage.set(id_key(service_id, name), id)
        storage.set(key(service_id, id, :name), name)
        storage.set(key(service_id, id, :parent_id), parent_id) if parent_id

        storage.sadd(id_set_key(service_id), id)

        save_children
      end

      def children
        @children ||= []
      end

      attr_writer :children

      module KeyHelpers
        def key(service_id, id, attribute)
          encode_key("metric/service_id:#{service_id}/id:#{id}/#{attribute}")
        end

        def id_key(service_id, name)
          encode_key("metric/service_id:#{service_id}/name:#{name}/id")
        end
        
        def id_set_key(service_id)
          encode_key("metrics/service_id:#{service_id}/ids")
        end

        def metric_names_key(service_id)
          encode_key("metrics/service_id:#{service_id}/metric_names")
        end

      end

      include KeyHelpers
      extend  KeyHelpers

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
