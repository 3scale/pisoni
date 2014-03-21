Bundler.require(:default, :test)
require 'minitest/autorun'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require '3scale/core'

# Use the synchronous redis client here, for simplicity.
module ThreeScale::Core
  def self.storage
    @storage ||= ::Redis.new(:db => 2)
  end
end

class MiniTest::Spec
  private

  def storage
    ThreeScale::Core.storage
  end
end
