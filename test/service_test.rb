require File.dirname(__FILE__) + '/test_helper'

class ServiceTest < Test::Unit::TestCase

  def test_save
    storage.expects(:set).with('service/provider_key:foo/id', '7001')
    service = Service.save(:provider_key => 'foo', :id => '7001')
  end

  def test_load_id
    storage.stubs(:get).with('service/provider_key:foo/id').returns('7002')
    assert_equal '7002', Service.load_id('foo')
  end
end
