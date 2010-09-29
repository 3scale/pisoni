$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

# require 'test/unit'
# require 'mocha'
# require 'redis'

require '3scale/core'

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
