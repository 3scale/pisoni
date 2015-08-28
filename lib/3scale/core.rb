require 'json'
require 'faraday'

require '3scale/core/version'
require '3scale/core/logger'

require '3scale/core/api_client'
require '3scale/core/application'
require '3scale/core/metric'
require '3scale/core/service'
require '3scale/core/usage_limit'
require '3scale/core/user'
require '3scale/core/event'
require '3scale/core/alert_limit'
require '3scale/core/errors'

module ThreeScale
  module Core
    extend self

    def faraday
      return @faraday if @faraday

      @faraday = Faraday.new(:url => donbot_url) do |f|
        f.adapter :net_http_persistent
      end
      @faraday.headers = {
        'User-Agent' => "3scale_core v#{ThreeScale::Core::VERSION}",
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
      @faraday.basic_auth(donbot_username, donbot_password)
      @faraday
    end

    def donbot_password
      'xxxxx'
    end

    def donbot_username
      'xxxxx'
    end

    def donbot_url=(url)
      @donbot_url = url
    end

    def donbot_url
      ENV['THREESCALE_CORE_INTERNAL_API'] || @donbot_url ||
        raise(UnknownDonbotAPIEndpoint)
    end

  end
end
