module PrivateEndpoints
  module Event
    def save(events)
      api_create(events, { uri: default_uri, prefix: :events })
    end
  end
end

ThreeScale::Core::Event.extend PrivateEndpoints::Event
