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
        service_id, id = attributes[:service_id], attributes[:id]
        api_update attributes, uri: "#{base_uri}/#{service_id}/metrics/#{id}"
      end

      def self.delete(service_id, id)
        api_delete({}, uri: "#{base_uri}/#{service_id}/metrics/#{id}")
      end

      def self.load_name(service_id, id)
        ret = api_do_get({}, uri: "#{base_uri}/#{service_id}/metrics/#{id}")
        ret[:attributes][:name] if ret[:ok]
      end

      def self.load_id(service_id, name)
        ret = api_do_get({}, uri: "#{base_uri}/#{service_id}/metrics/name/#{name}")
        ret[:attributes][:id] if ret[:ok]
      end

      # XXX depends on UsageLimit
      def self.load_all_ids(service_id)
        ret = api_do_get({}, uri: "#{base_uri}/#{service_id}/metrics/all")
        ret[:attributes][:ids] if ret[:ok]
      end

    end
  end
end
