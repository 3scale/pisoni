$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'bundler/setup'
Bundler.require(:default, :development, :test)

class Test::Unit::TestCase
  include ThreeScale::Core
end

module VCRFilteredSerializer
  require 'time'
  require 'uri'

  class << self
    attr_accessor :serializer

    # remove variable data from all request headers
    def serialize(hash)
      hash['http_interactions'].each do |interaction|
        interaction['request']['headers'].delete 'User-Agent'
        interaction['recorded_at'] = FIXED_TIME
        uri = URI.parse(interaction['request']['uri'])
        uri.hostname = 'localhost'
        uri.port = 3001
        interaction['request']['uri'] = uri.to_s
        interaction['response']['headers']['server'] = [to_s]
      end
      serializer.serialize hash
    end

    def method_missing(*args, &blk)
      serializer.send(*args, &blk)
    end

    def respond_to_missing?(*args)
      serializer.respond_to?(*args)
    end

    private

    FIXED_TIME = Time.gm(1980, 9, 10, 15, 00).httpdate
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :faraday
  #c.debug_logger = File.open('vcr_debug.log', 'w')
  VCRFilteredSerializer.serializer = c.cassette_serializers[:yaml]
  c.cassette_serializers[:filtered] = VCRFilteredSerializer
  full_build = ENV['FULL_BUILD'] == '1'
  c.default_cassette_options = { allow_playback_repeats: true,
                                 record: full_build ? :all : :new_episodes,
                                 serialize_with: :filtered,
                                 match_requests_on: [:method, :path, :query, :body]
                               }
end
