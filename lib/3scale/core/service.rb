module ThreeScale
  module Core
    class Service < APIClient::Resource
      attributes :provider_key, :id, :backend_version, :referrer_filters_required,
                 :user_registration_required, :default_user_plan_id,
                 :default_user_plan_name, :version, :default_service

      class << self
        def base_uri
          '/internal/services'
        end

        def load_by_id(service_id)
          api_read({}, uri: "#{base_uri}/#{service_id}", rprefix: '')
        end

        def delete_by_id!(service_id)
          api_delete({}, uri: "#{base_uri}/#{service_id}")
        rescue APIClient::APIError => e
          raise ServiceIsDefaultService, service_id if e.response.status == 400
          raise
        end

        def save!(attributes)
          id = attributes.fetch(:id)
          api_update(attributes, uri: "#{base_uri}/#{id}")
        rescue APIClient::APIError => e
          raise ServiceRequiresDefaultUserPlan if e.response.status == 400
          raise
        end

        def change_provider_key!(old_key, new_key)
          ret = api_do_put({ new_key: new_key },
                     uri: "#{base_uri}/change_provider_key/#{old_key}",
                     prefix: '')
          ret[:ok]
        rescue APIClient::APIError => e
          ex = if e.response.status == 400 && e.attributes[:error]
                 provider_key_exception(e.attributes[:error], old_key, new_key)
               end
          raise ex || e
        end

        def make_default(service_id)
          save! id: service_id, default_service: true
        end

        private

        def provider_key_exception(error, old_key, new_key)
          case error
          when /does not exist/
            ProviderKeyNotFound.new old_key
          when /already exists/
            ProviderKeyExists.new new_key
          when /are not valid/
            InvalidProviderKeys.new
          else
            nil
          end
        end
      end

      def referrer_filters_required?
        @referrer_filters_required
      end

      def user_registration_required?
        @user_registration_required
      end

      def save!
        self.class.save! attributes
      end

      def user_add(username)
        Core.faraday.post "services/#{id}/users", {username: username}.to_json
      end

      def user_delete(username)
        Core.faraday.delete "services/#{id}/users/#{username}"
      end

    end
  end
end
