require_relative '../test/test_helper'
require 'minitest/autorun'

class MiniTest::Spec
  before { storage.flushdb }

  private

  def storage
    ThreeScale::Core.storage
  end
end

