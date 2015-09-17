module PrivateEndpoints
  module ServiceError
    def save(service_id, errors)
      api_create(
          errors, { uri: service_errors_uri(service_id), prefix: :errors })
    end
  end
end

ThreeScale::Core::ServiceError.extend PrivateEndpoints::ServiceError
