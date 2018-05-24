require 'uri'
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
require '3scale/core/application_key'
require '3scale/core/application_referrer_filter'
require '3scale/core/service_error'
require '3scale/core/transaction'
require '3scale/core/utilization'
require '3scale/core/service_token'

module ThreeScale
  module Core
    extend self

    attr_accessor :username, :password
    attr_writer :url

    def faraday
      return @faraday if @faraday

      url = self.url
      @faraday = Faraday.new(url: url) do |f|
        f.adapter :net_http_persistent
      end
      @faraday.headers = {
        'User-Agent' => "pisoni v#{ThreeScale::Core::VERSION}",
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }

      if @username.nil? && @password.nil?
        # even though the url may contain the user info, turns out Faraday is
        # not really picking it up, so must fill it in if present in the URL and
        # no previous setting was done (ie. assigning username or password).
        uri = URI.parse url
        @username = uri.user
        @password = uri.password
      end

      @faraday.basic_auth(@username, @password) if @username || @password
      @faraday
    end

    def url
      ENV['THREESCALE_CORE_INTERNAL_API'] || @url ||
        raise(UnknownAPIEndpoint)
    end

  end
end
