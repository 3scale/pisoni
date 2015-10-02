module ThreeScale
  module Core
    class ServiceError < APIClient::Resource
      attributes :code, :message, :timestamp

      default_uri '/internal/services/'

      def self.service_errors_uri(service_id)
        "#{default_uri}#{service_id}/errors/"
      end
      private_class_method :service_errors_uri

      def self.load_all(service_id, options={})
        result = api_do_get(options,
                            { uri: service_errors_uri(service_id),
                              prefix: '',
                              rprefix: :errors }) do |response, attrs|
          if response.status == 400 && attrs[:error] == 'per_page needs to be > 0'
            raise InvalidPerPage.new
          end
          [true, nil]
        end

        APIClient::Collection.new(result[:attributes].map { |attrs| new attrs },
                                  result[:response_json][:count])
      end

      def self.delete_all(service_id)
        api_delete({}, uri: service_errors_uri(service_id))
      end
    end
  end
end
