module ThreeScale
  module Core
    class Application < APIClient::Resource
      ## added the :user_required to distinguish between types of application:
      ## false is the default value, do not expect user_id or ignore it if it happends
      ## true, the user_id must be defined + the user of the service (service_id#user_id),
      ## user_id is typically the UUID of a cellphone, or the twitter account
      attributes :service_id, :id, :state, :plan_id, :plan_name,
                    :redirect_url, :user_required, :version

      def version=(version)
        @version = version.to_i
      end

      def self.base_uri
        '/internal/services'
      end

      def base_uri
        self.class.base_uri
      end

      def self.load(service_id, id)
        api_read({}, uri: "#{base_uri}/#{service_id}/applications/#{id}")
      end

      def self.save(attributes)
        service_id, id = attributes.fetch(:service_id), attributes.fetch(:id)
        if load(service_id, id)
          api_update attributes, uri: "#{base_uri}/#{service_id}/applications/#{id}"
        else
          api_create attributes, uri: "#{base_uri}/#{service_id}/applications/#{id}"
        end
      end

      def self.delete(service_id, id)
        api_delete({}, uri: "#{base_uri}/#{service_id}/applications/#{id}")
      end

      def save
        api_save uri: "#{base_uri}/#{service_id}/applications/#{id}"
      end

      def user_required?
        user_required
      end

      # XXX Old API. Just returns an id. DEPRECATED.
      def self.load_id_by_key(service_id, user_key)
        ret = api_do_get({}, uri: "#{base_uri}/#{service_id}/applications/key/#{user_key}")
        ret[:ok] ? ret[:attributes][:id] : nil
      end

      def self.save_id_by_key(service_id, user_key, id)
        raise ApplicationHasInconsistentData.new(id, user_key) if (service_id.nil? || id.nil? || user_key.nil? || service_id=="" || id=="" || user_key=="")
        ret = api_do_put({}, uri: "#{base_uri}/#{service_id}/applications/#{id}/key/#{user_key}")
        ret[:ok]
      end

      def self.delete_id_by_key(service_id, user_key)
        api_delete({}, uri: "#{base_uri}/#{service_id}/applications/key/#{user_key}")
      end

    end
  end
end
