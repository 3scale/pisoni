require 'base64'

module ThreeScale
  module Core
    class ApplicationReferrerFilter < APIClient::Resource
      default_uri '/internal/services/'

      def self.load_all(service_id, application_id)
        results = api_do_get({},
                             rprefix: :referrer_filters,
                             uri: base_uri(service_id, application_id))
        results[:attributes]
      end

      def self.save(service_id, application_id, value)
        result = api_do_post({ referrer_filter: value },
                             uri: base_uri(service_id, application_id),
                             prefix: '')
        result[:response_json][:referrer_filter]
      end

      def self.delete(service_id, application_id, value)
        encoded_value = Base64.urlsafe_encode64(value)
        api_delete({}, uri: base_uri(service_id, application_id) + "/#{encoded_value}")
      end

      def self.base_uri(service_id, application_id)
        "#{default_uri}#{service_id}/applications/#{application_id}/referrer_filters"
      end
      private_class_method :base_uri
    end
  end
end
