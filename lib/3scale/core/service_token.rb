module ThreeScale
  module Core
    class ServiceToken < APIClient::Resource

      default_uri '/internal/service_tokens/'

      class << self

        def save!(attributes)
          api_do_post(attributes, prefix: :service_tokens) do |result|

            status = result[:response].status

            if status == 400
              raise ServiceTokenMissingParameter, result[:response_json][:error]
            end

            if status == 422
              case result[:response_json][:error]
              when /Service ID/
                raise ServiceTokenRequiresServiceId
              when /Service token/
                raise ServiceTokenRequiresToken
              end
            end

            true
          end
        end

        def delete(attributes)
          result = api_do_delete(attributes, uri: default_uri, prefix: :service_tokens)

          result[:response_json][:count]
        end
      end
    end
  end
end
