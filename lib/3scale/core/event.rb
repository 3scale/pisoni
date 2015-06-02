module ThreeScale
  module Core
    class Event < APIClient::Resource
      attributes :id, :type, :timestamp, :object

      def self.base_uri
        '/internal/events'
      end

      def base_uri
        self.class.base_uri
      end

      def self.load_all
        results = api_do_get({}, rprefix: :events, build: false, uri: "#{base_uri}/")
        results[:attributes].map { |attrs| new attrs }
      end

      def self.delete(id)
        api_delete({}, uri: "#{base_uri}/#{id}")
      end

      def self.delete_upto(id)
        results = api_do_delete({ upto_id: id }, prefix: '', uri: "#{base_uri}/")
        results[:attributes][:num_events]
      end
    end
  end
end
