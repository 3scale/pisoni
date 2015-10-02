module ThreeScale
  module Core
    class Event < APIClient::Resource
      attributes :id, :type, :timestamp, :object

      def self.load_all
        results = api_do_get({}, rprefix: :events)
        results[:attributes].map { |attrs| new attrs }
      end

      def self.delete(id)
        api_delete({}, uri: event_uri(id))
      end

      def self.delete_upto(id)
        results = api_do_delete({ upto_id: id }, prefix: '')
        results[:response_json][:num_events]
      end

      def self.event_uri(id)
        "#{default_uri}#{id}"
      end
      private_class_method :event_uri
    end
  end
end
