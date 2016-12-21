module ThreeScale
  module Core
    class User < APIClient::Resource
      attributes :service_id, :username, :state, :plan_id, :plan_name, :version

      default_uri '/internal/services/'

      def self.base_uri(service_id, username)
        "#{default_uri}#{service_id}/users/#{username}"
      end
      private_class_method :base_uri

      def self.check_params(service_id, username)
        raise UserRequiresUsername if username.nil? || username == ''.freeze
        raise UserRequiresServiceId if service_id.nil? || service_id == ''.freeze
      end
      private_class_method :check_params

      def self.load(service_id, username)
        check_params service_id, username
        api_read({}, uri: base_uri(service_id, username))
      end

      def self.save!(attributes)
        service_id, username = attributes[:service_id], attributes[:username]
        check_params service_id, username
        api_update(attributes,
                   uri: base_uri(service_id, username)) do |result|
          if result[:response].status == 400
            if result[:response_json][:error] =~ /requires a valid service/
              raise UserRequiresValidServiceId.new(service_id)
            elsif result[:response_json][:error] =~ /requires a defined plan/
              raise UserRequiresDefinedPlan.new(attributes[:plan_id],
                                                attributes[:plan_name])
            end
          end
          true
        end
      end

      def self.delete!(service_id, username)
        check_params service_id, username
        api_delete({}, uri: base_uri(service_id, username))
      end
    end
  end
end
