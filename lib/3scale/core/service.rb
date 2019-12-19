module ThreeScale
  module Core
    class Service < APIClient::Resource
      attributes :provider_key, :id, :backend_version, :referrer_filters_required,
                 :user_registration_required, :default_user_plan_id,
                 :default_user_plan_name, :default_service, :state

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
          api_update(attributes, uri: service_uri(id))
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

        def delete_stats(service_id, delete_job)
          api_delete(delete_job, uri: "#{service_uri(service_id)}/stats", prefix: '')
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

      def initialize(attributes = {})
        @state = :active
        super(attributes)
      end

      def activate
        self.state = :active
      end

      def deactivate
        self.state = :suspended
      end

      def referrer_filters_required?
        @referrer_filters_required
      end

      def user_registration_required?
        @user_registration_required
      end

      def active?
        state == :active
      end

      def save!
        self.class.save! attributes
      end

      private

      def state=(value)
        # only :active or nil will be considered as :active
        @state = value.nil? || value.to_sym == :active ? :active : :suspended
      end
    end
  end
end
