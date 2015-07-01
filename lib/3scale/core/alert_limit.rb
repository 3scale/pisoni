module ThreeScale
  module Core
    class AlertLimit < APIClient::Resource
      attributes :service_id, :value

      default_uri '/internal/services/'

      def self.load_all(service_id)
        results = api_do_get({}, rprefix: :alert_limits, uri: alert_limit_uri(service_id))
        results[:attributes].map { |attrs| new(attrs) }
      end

      def self.base_uri(service_id)
        "#{default_uri}#{service_id}/alert_limits/"
      end
      private_class_method :base_uri

      def self.alert_limit_uri(service_id, value = nil)
        "#{base_uri(service_id)}#{value}"
      end
      private_class_method :alert_limit_uri

      def self.save(service_id, value)
        api_save({value: value}, uri: alert_limit_uri(service_id), prefix: :alert_limit)
      end

      def self.delete(service_id, value)
        api_delete({}, uri: alert_limit_uri(service_id, value))
      end
    end
  end
end
