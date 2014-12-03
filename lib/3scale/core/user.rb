module ThreeScale
  module Core
    class User < APIClient::Resource
      attributes :service_id, :username, :state, :plan_id, :plan_name, :version

      def self.load(service_id, username)
        check_params service_id, username
        api_read({}, uri: base_uri(service_id, username))
      end

      def self.save!(attributes)
        service_id, username = attributes[:service_id], attributes[:username]
        check_params service_id, username
        api_update attributes, uri: base_uri(service_id, username)
      rescue APIClient::APIError => e
        if e.response.status == 400
          errmsg = e.attributes[:error]
          if errmsg =~ /requires a valid service/
            raise UserRequiresValidServiceId.new(service_id)
          elsif errmsg =~ /requires a defined plan/
            plan_id, plan_name = attributes[:plan_id], attributes[:plan_name]
            raise UserRequiresDefinedPlan.new(plan_id, plan_name)
          end
        end
        raise e
      end

      def self.delete!(service_id, username)
        check_params service_id, username
        api_delete({}, uri: base_uri(service_id, username))
      end

      private

      def self.base_uri(service_id, username)
        "/internal/services/#{service_id}/users/#{username}"
      end

      def self.check_params(service_id, username)
        raise UserRequiresUsername if username.nil?
        raise UserRequiresServiceId if service_id.nil?
      end

    end
  end
end
