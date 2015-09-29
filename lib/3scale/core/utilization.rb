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
                            rprefix: :utilization) do |response, _|
          if response.status == 404
            case parse_json(response.body)[:error]
              when 'service not found'
                raise ServiceNotFound.new(service_id)
              when 'application not found'
                raise ApplicationNotFound.new(app_id)
              else
                raise Error.new('Unknown error')
            end
          end
          [true, nil] # error != 404, raise APIError
        end

        usage_reports = result[:attributes].map { |attrs| new attrs }
        APIClient::Collection.new(usage_reports)
      end
    end
  end
end
