$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'bundler/setup'
Bundler.require(:default, :development, :test)

# Use the synchronous redis client here, for simplicity.
module ThreeScale::Core
  def self.storage
    @storage ||= ::Redis.new(:db => 2)
  end
end

class Test::Unit::TestCase
  include ThreeScale::Core

  private

  def storage
    ThreeScale::Core.storage
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :faraday
  #c.debug_logger = File.open('vcr_debug.log', 'w')
  full_build = ENV['FULL_BUILD'] == '1'
  c.default_cassette_options = { allow_playback_repeats: true, record: full_build ? :all : :new_episodes }
end
