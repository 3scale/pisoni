module ThreeScale
  module Core
    class Metric < APIClient::Resource
      attributes :service_id, :id, :parent_id, :name

      default_uri '/internal/services/'

      def self.base_uri(service_id)
        "#{default_uri}#{service_id}/metrics/"
      end
      private_class_method :base_uri

      def self.metric_uri(service_id, id)
        "#{base_uri(service_id)}#{id}"
      end
      private_class_method :metric_uri

      def self.load(service_id, id)
        api_read({}, uri: metric_uri(service_id, id))
      end

      def self.save(attributes)
        service_id, id = attributes.fetch(:service_id), attributes.fetch(:id)
        api_update attributes, uri: metric_uri(service_id, id)
      end

      def self.delete(service_id, id)
        api_delete({}, uri: metric_uri(service_id, id))
      end
    end
  end
end
