Bundler.require(:default, :test)
require 'minitest/autorun'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require '3scale/core'

require 'vcr'

module ThreeScale::Core
  # Use the synchronous redis client here, for simplicity.
  def self.storage
    @storage ||= ::Redis.new(:db => 2)
  end
end

class MiniTest::Spec
  before { storage.flushdb }

  private

  def storage
    ThreeScale::Core.storage
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :faraday
end
