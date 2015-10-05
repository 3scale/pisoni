module ThreeScale
  module Core
    class Service < APIClient::Resource
      attributes :provider_key, :id, :backend_version, :referrer_filters_required,
                 :user_registration_required, :default_user_plan_id,
                 :default_user_plan_name, :version, :default_service

      class << self
        def load_by_id(service_id)
          # This function needs to be compatible with two versions of backend.
          # The new one returns the service in a hash and we need to use a
          # prefix to extract it. In the old version, the service was returned
          # directly in the response like:
          # { :provider_key => 'X', :id => 'Y', ... }

          # Compatible with the new version of backend
          result = api_read({}, uri: service_uri(service_id), rprefix: :service)
          return result unless result.nil?

          # If result is nil, it might be because there was an error (the
          # service does not exist) or because the code is using the old
          # version of backend. If the response is nil using and empty prefix,
          # it means that we are using the new version
          response_without_prefix = api_do_get(
              {}, uri: service_uri(service_id), rprefix: '')

          # Using new backend version
          return nil if response_without_prefix.nil?

          # Using old backend version
          response_json = response_without_prefix[:response_json]
          response_json[:error] ? nil : new(response_json)
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
