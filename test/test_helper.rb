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
  def before_setup
    storage.flushall
  end

  private

  def storage
    ThreeScale::Core.storage
  end
end

class Test::Unit::TestCase
  include ThreeScale::Core
  include CoreTests
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :faraday
  #c.debug_logger = File.open('vcr_debug.log', 'w')
  full_build = ENV['FULL_BUILD'] == '1'
  c.default_cassette_options = { allow_playback_repeats: true, record: full_build ? :all : :new_episodes }
end
