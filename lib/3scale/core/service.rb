module ThreeScale
  module Core
    class Service
      include Storable

      ATTRIBUTES = %w(provider_key id backend_version referrer_filters_required
        user_registration_required default_user_plan_id default_user_plan_name
        version default_service)

      attr_accessor *(ATTRIBUTES.map { |attr| attr.to_sym })

      class << self

        def load_by_id(service_id)
          response = Core.faraday.get "services/#{service_id}"
          service = JSON.parse(response.body)

          attributes = {}
          ATTRIBUTES.each { |attr| attributes[attr] = service[attr] }
          new attributes
        end

        def delete_by_id!(service_id, options = {})
          response = Core.faraday.delete "services/#{service_id}", options

          if response.status != 200
            raise ServiceIsDefaultService, service_id if response.status == 400
            raise "Error deleting a Service: #{service_id}, options: #{options.inspect},
              response code: #{response.satus}, response body: #{response.body.inspect}"
          end
          return true
        end

        def save!(attributes)
          response = Core.faraday.post "services/", service: attributes

          if response.status != 201
            if response.status == 400 &&
              (json = json(response))['error'] =~ /require a default user plan/
              raise ServiceRequiresDefaultUserPlan
            else
              raise "Error saving a Service, attributes: #{attributes.inspect},
                response code: #{response.status}, response body: #{response.body.inspect}"
            end
          end
          return true
        end

        def change_provider_key!(old_key, new_key)
          response = Core.faraday.put "services/change_provider_key/#{old_key}",
            new_key: new_key

          if (status = response.status) != 200
            json_response = json(response)
            if status == 400 && json_response['error'] =~ /does not exist/
              raise ProviderKeyNotFound, old_key
            elsif status == 400 && json_response['error'] =~ /already exists/
              raise ProviderKeyExists, new_key
            elsif status == 400 && json_response['error'] =~ /are not valid/
              raise InvalidProviderKeys
            else
              raise "Error changing a provider key, old_key: #{old_key.inspect},
                new_key: #{new_key.inspect}, response code: #{response.status},
                response body: #{response.body.inspect}"
            end
          end

          return true
        end

        private

        def json(response)
          JSON.parse(response.body)
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

      def attributes
        attrs = {}
        ATTRIBUTES.each{ |attr| attrs[attr.to_sym] = self.send(attr.to_sym) }

        attrs
      end

      def make_default
        self.default_service = true
        self.save!
      end

      # TODO: Remove once unused.
      def self.incr_version(id)
        storage.incrby(storage_key(id,:version),1)
      end

      # TODO: Remove once unused.
      def self.storage_key(id, attribute)
        encode_key("service/id:#{id}/#{attribute}")
      end

      ## ---- add the user dimension. Users are unique on the service scope
      ## returns true if the user is new
      def user_add(username)
        isnew = storage.sadd(storage_key("user_set"),username)
        self.class.incr_version(id)
        return isnew
      end

      def user_delete(username)
        storage.srem(storage_key("user_set"),username)
        self.class.incr_version(id)
      end

      def user_exists?(username)
        exists = storage.sismember(storage_key("user_set"),username)
      end

      def user_size
        storage.scard(storage_key("user_set"))
      end

      private

      def default_service?
        @default_service
      end

    end
  end
end
