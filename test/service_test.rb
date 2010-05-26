require File.dirname(__FILE__) + '/test_helper'

class ServiceTest < Test::Unit::TestCase
  def setup
    storage.flushdb
  end

  def test_save
    Service.save(:provider_key => 'foo', :id => 7001)
    assert_equal '7001', storage.get('service/provider_key:foo/id')
  end

  def test_load_id
    Service.save(:provider_key => 'foo', :id => 7002)
    assert_equal '7002', Service.load_id('foo')
  end
end
