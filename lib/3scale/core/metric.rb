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

      private

      def self.load_metric_api(service_id, attr, uri)
        ret = api_do_get({}, uri: "#{base_uri}/#{service_id}/metrics/#{uri}")
        ret[:attributes][attr] if ret[:ok]
      end
    end
  end
end
