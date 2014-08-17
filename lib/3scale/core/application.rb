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

      def self.load(service_id, id)
        api_read({service_id: service_id, id: id}, prefix: :app)
      end

      # XXX Old API. Just returns an id.
      def self.load_id_by_key(service_id, user_key)
        ret = api_do_get({service_id: service_id, user_key: user_key}, prefix: :app, uri: "#{default_uri}/by_key")
        ret[:ok] ? ret[:attributes][:id] : nil
      end

      def self.save(attributes)
        api_save attributes, prefix: :app
      end

      def self.save_id_by_key(service_id, user_key, id)
        raise ApplicationHasInconsistentData.new(id, user_key) if (service_id.nil? || id.nil? || user_key.nil? || service_id=="" || id=="" || user_key=="")
        ret = api_do_post({service_id: service_id, user_key: user_key, id: id}, prefix: :app, uri: "#{default_uri}/by_key")
        ret[:ok]
      end

      def self.delete(service_id, id)
        api_delete({service_id: service_id, id: id}, prefix: :app)
      end

      # XXX Old API. Just deletes a key.
      def self.delete_id_by_key(service_id, user_key)
        api_delete({service_id: service_id, user_key: user_key}, prefix: :app, uri: "#{default_uri}/by_key")
      end

      def save
        api_save prefix: :app
      end

      def user_required?
        user_required
      end

    end
  end
end
