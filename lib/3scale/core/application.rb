require 'cgi'

module ThreeScale
  module Core
    class Application < APIClient::Resource
      ## added the :user_required to distinguish between types of application:
      ## false is the default value, do not expect user_id or ignore it if it happends
      ## true, the user_id must be defined + the user of the service (service_id#user_id),
      ## user_id is typically the UUID of a cellphone, or the twitter account
      attributes :service_id, :id, :state, :plan_id, :plan_name,
                 :redirect_url, :user_required

      default_uri '/internal/services/'

      def self.base_uri(service_id)
        "#{default_uri}#{service_id}/applications/"
      end
      private_class_method :base_uri

      def self.app_uri(service_id, id)
        escaped_id = CGI::escape(id.to_s)

        "#{base_uri(service_id)}#{escaped_id}"
      end
      private_class_method :app_uri

      def self.key_uri(service_id, key)
        escaped_key = CGI::escape(key.to_s)

        "#{base_uri(service_id)}key/#{escaped_key}"
      end
      private_class_method :key_uri

      def self.load(service_id, id)
        api_read({}, uri: app_uri(service_id, id))
      end

      def self.save(attributes)
        service_id, id = attributes.fetch(:service_id), attributes.fetch(:id)
        api_update attributes, uri: app_uri(service_id, id)
      end

      def self.delete(service_id, id)
        api_delete({}, uri: app_uri(service_id, id))
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

      def active?
        state == :active
      end

      def save
        api_save uri: self.class.send(:app_uri, service_id, id)
      end

      def user_required?
        user_required
      end

      # XXX Old API. Just returns an id. DEPRECATED.
      def self.load_id_by_key(service_id, user_key)
        ret = api_do_get({}, uri: key_uri(service_id, user_key))
        ret[:ok] ? ret[:attributes][:id] : nil
      end

      def self.save_id_by_key(service_id, user_key, id)
        raise ApplicationHasInconsistentData.new(id, user_key) if (service_id.nil? || id.nil? || user_key.nil? || service_id=="" || id=="" || user_key=="")
        escaped_key = CGI::escape(user_key)
        ret = api_do_put({}, uri: "#{app_uri(service_id, id)}/key/#{escaped_key}")
        ret[:ok]
      end

      def self.delete_id_by_key(service_id, user_key)
        api_delete({}, uri: key_uri(service_id, user_key))
      end

      private

      def state=(value)
        # only :active or nil will be considered as :active
        @state = value.nil? || value.to_sym == :active ? :active : :suspended
      end
    end
  end
end
