module ThreeScale
  module Core
    class Transaction < APIClient::Resource
      attributes :application_id, :usage, :timestamp

      default_uri '/internal/services/'

      def self.transactions_uri(service_id)
        "#{default_uri}#{service_id}/transactions/"
      end
      private_class_method :transactions_uri

      def self.load_all(service_id)
        result = api_do_get({}, { uri: transactions_uri(service_id),
                                  rprefix: :transactions })

        if !result[:ok] && result[:response].status == 404
          raise ServiceNotFound.new(service_id)
        end

        APIClient::Collection.new(result[:attributes].map { |attrs| new attrs })
      end
    end
  end
end
