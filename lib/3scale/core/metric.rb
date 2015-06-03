module ThreeScale
  module Core
    class Metric < APIClient::Resource
      attributes :service_id, :id, :parent_id, :name

      def self.base_uri
        '/internal/services'
      end

      def base_uri
        self.class.base_uri
      end

      def self.load(service_id, id)
        api_read({}, uri: "#{base_uri}/#{service_id}/metrics/#{id}")
      end

      def self.save(attributes)
        service_id, id = attributes.fetch(:service_id), attributes.fetch(:id)
        api_update attributes, uri: "#{base_uri}/#{service_id}/metrics/#{id}"
      end

      def self.delete(service_id, id)
        api_delete({}, uri: "#{base_uri}/#{service_id}/metrics/#{id}")
      end
    end
  end
end
