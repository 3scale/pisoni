require 'json'

require '3scale/core/storage_key_helpers'
require '3scale/core/storable'

require '3scale/core/application'
require '3scale/core/metric'
require '3scale/core/service'
require '3scale/core/usage_limit'
require '3scale/core/user'
require '3scale/core/errors'

module ThreeScale
  module Core
    extend self

    def storage
      raise 'You have to reimplement this method to return a storage instance.'
    end

    def faraday
      return @faraday if @faraday

      @faraday = Faraday.new(:url => internal_api_url)
      @faraday.headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
      @faraday.basic_auth(donbot_username, donbot_password)
      @faraday
    end

    def donbot_password
      ENV['DONBOT_AUTH_PASSWORD'] || 'xxxxx'
    end

    def donbot_username
      ENV['DONBOT_AUTH_PASSWORD'] || 'xxxxx'
    end

    def internal_api_url
      ENV['THREESCALE_CORE_INTERNAL_API'] || 'http://localhost:3000/internal/'
    end

  end
end
