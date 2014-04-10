require_relative '../test/test_helper'
require 'minitest/autorun'

class MiniTest::Spec
  include CoreTests

  before { storage.flushall }
end

