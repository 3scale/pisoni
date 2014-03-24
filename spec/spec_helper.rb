Bundler.require(:default, :test)
require 'minitest/autorun'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require '3scale/core'

module ThreeScale::Core

  # Stub the HTTP API calls
  def self.faraday
    @faraday ||= Faraday.new do |builder|
      builder.adapter :test, faraday_stub_adapter
    end
  end

  def self.faraday_stub_adapter
    @faraday_stub_adapter ||= Faraday::Adapter::Test::Stubs.new
  end

  # Use the synchronous redis client here, for simplicity.
  def self.storage
    @storage ||= ::Redis.new(:db => 2)
  end
end

class MiniTest::Spec
  before :each do
    storage.flushdb
  end

  private

  def storage
    ThreeScale::Core.storage
  end

  def faraday_stub
    ThreeScale::Core.faraday_stub_adapter
  end
end
