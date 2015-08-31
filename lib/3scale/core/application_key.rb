module ThreeScale
  module Core
    class ApplicationKey < APIClient::Resource
      attributes :service_id, :application_id, :value

      default_uri '/internal/services/'

      def self.load_all(service_id, application_id)
        results = api_do_get({}, rprefix: :application_keys, uri: application_key_uri(service_id, application_id))
        return [] if results[:attributes].is_a?(Hash) && results[:attributes][:error]

        results[:attributes].map { |attrs| new(attrs) }
      end

      def self.save(service_id, application_id, value)
        api_save({value: value}, uri: application_key_uri(service_id, application_id), prefix: :application_key)
      end

      def self.delete(service_id, application_id, value)
        api_delete({}, uri: application_key_uri(service_id, application_id, value))
      end

      def self.base_uri(service_id, application_id)
        "#{default_uri}#{service_id}/applications/#{application_id}/keys/"
      end
      private_class_method :base_uri

      def self.application_key_uri(service_id, application_id, value = nil)
        "#{base_uri(service_id, application_id)}#{value}"
      end
      private_class_method :application_key_uri
    end
  end
end
