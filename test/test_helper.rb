$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

require '3scale/core'
require 'vcr'

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
  c.default_cassette_options = {allow_playback_repeats: true}
end
