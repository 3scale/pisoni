module ThreeScale
  module Core
    class Service < APIClient::Resource
      attributes :provider_key, :id, :backend_version, :referrer_filters_required,
                 :user_registration_required, :default_user_plan_id,
                 :default_user_plan_name, :version, :default_service

      class << self
        def load_by_id(service_id)
          api_read({}, uri: service_uri(service_id), rprefix: :service)
        end

        def delete_by_id!(service_id)
          api_delete({}, uri: service_uri(service_id)) do |result|
            if result[:response].status == 400
              raise ServiceIsDefaultService, service_id
            end
          end
        end

        def save!(attributes)
          id = attributes.fetch(:id)
          api_update(attributes, uri: service_uri(id)) do |result|
            if result[:response].status == 400
              raise ServiceRequiresDefaultUserPlan
            end
            true
          end
        end

        def change_provider_key!(old_key, new_key)
          ret = api_do_put({ new_key: new_key },
                           uri: "#{default_uri}change_provider_key/#{old_key}",
                           prefix: '') do |result|
            if result[:response].status == 400
              exception = provider_key_exception(
                  result[:response_json][:error], old_key, new_key)
              raise exception if exception
            end
            true
          end
          ret[:ok]
        end

        def make_default(service_id)
          save! id: service_id, default_service: true
        end

        def set_log_bucket(id, bucket)
          ret = api_do_put({ bucket: bucket },
                           uri: "#{service_uri(id)}/logs_bucket",
                           prefix: '') do |result|
            if result[:response].status == 400 &&
                result[:response_json][:error] == 'bucket is missing'
              raise InvalidBucket.new
            end
            true
          end
          ret[:ok]
        end

        def clear_log_bucket(id)
          ret = api_do_delete({}, uri: "#{service_uri(id)}/logs_bucket", prefix: '')
          ret[:ok]
        end

        private

        def service_uri(id)
          "#{default_uri}#{id}"
        end

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
    end
  end
end
