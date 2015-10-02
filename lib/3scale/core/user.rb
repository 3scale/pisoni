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
        raise UserRequiresUsername if username.nil?
        raise UserRequiresServiceId if service_id.nil?
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
                   uri: base_uri(service_id, username)) do |response, attrs|
          if response.status == 400
            if attrs[:error] =~ /requires a valid service/
              raise UserRequiresValidServiceId.new(service_id)
            elsif attrs[:error] =~ /requires a defined plan/
              raise UserRequiresDefinedPlan.new(attributes[:plan_id],
                                                attributes[:plan_name])
            end
          end
          [true, nil]
        end
      end

      def self.delete!(service_id, username)
        check_params service_id, username
        api_delete({}, uri: base_uri(service_id, username))
      end
    end
  end
end
