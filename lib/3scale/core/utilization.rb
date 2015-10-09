module ThreeScale
  module Core
    class Utilization < APIClient::Resource
      attributes :period, :metric_name, :max_value, :current_value

      default_uri '/internal/services/'

      def self.utilization_uri(service_id, app_id)
        "#{default_uri}#{service_id}/applications/#{app_id}/utilization/"
      end
      private_class_method :utilization_uri

      def self.load(service_id, app_id)
        result = api_do_get({},
                            uri: utilization_uri(service_id, app_id),
                            rprefix: :utilization) do |result|
          return nil if result[:response].status == 404
          true
        end

        return nil if result.nil?

        usage_reports = result[:attributes].map { |attrs| new attrs }
        APIClient::Collection.new(usage_reports)
      end
    end
  end
end
