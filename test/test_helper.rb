$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'bundler/setup'
Bundler.require(:default, :development, :test)

# Use the synchronous redis client here, for simplicity.
module ThreeScale::Core
  def self.storage
    @storage ||= ::Redis.new(:db => 2)
  end
end

module CoreTests

  private

  def storage
    ThreeScale::Core.storage
  end
end

class Test::Unit::TestCase
  include ThreeScale::Core
  include CoreTests

  def before_setup
    storage.flushall
  end
end

module VCRSerializerWOUserAgent
  require 'time'

  class << self
    attr_accessor :serializer

    # remove user agent from all request headers
    def serialize(hash)
      hash['http_interactions'].each do |interaction|
        interaction['request']['headers'].delete 'User-Agent'
        interaction['recorded_at'] = FIXED_TIME
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
  VCRSerializerWOUserAgent.serializer = c.cassette_serializers[:yaml]
  c.cassette_serializers[:no_useragent] = VCRSerializerWOUserAgent
  full_build = ENV['FULL_BUILD'] == '1'
  c.default_cassette_options = { allow_playback_repeats: true,
                                 record: full_build ? :all : :new_episodes,
                                 serialize_with: :no_useragent
                               }

end
