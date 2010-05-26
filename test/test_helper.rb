$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'mocha'

require '3scale/core'

class TestStorage
end

ThreeScale::Core.storage = TestStorage.new

class Test::Unit::TestCase
  include ThreeScale::Core

  private

  def storage
    ThreeScale::Core.storage
  end
end
