require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ServiceTest < Test::Unit::TestCase
  def setup
    storage.flushdb
  end

  def test_save
    Service.save(:provider_key => 'foo', :id => 7001, :referrer_filters_required => true)
    assert_equal '7001', storage.get('service/provider_key:foo/id')
    assert_equal '1',    storage.get('service/id:7001/referrer_filters_required')
  end

  def test_load
    storage.set('service/provider_key:foo/id', '7001')
    storage.set('service/id:7001/referrer_filters_required', '1')

    service = Service.load('foo')

    assert_not_nil service
    assert_equal 'foo',  service.provider_key
    assert_equal '7001', service.id
    assert service.referrer_filters_required?
  end

  def test_delete
    Service.save(:provider_key => 'foo', :id => 7003, :referrer_filters_required => true)
    Service.delete('foo')

    assert_nil storage.get('service/provider_key:foo/id')
    assert_nil storage.get('service/id:7003/referrer_filters_required')
  end

  def test_exists?
    assert !Service.exists?('foo')
    Service.save(:provider_key => 'foo', :id => 7004)
    assert  Service.exists?('foo')
  end
  
  def test_load_id
    storage.set('service/provider_key:foo/id', 7002)
    assert_equal '7002', Service.load_id('foo')
  end

  def test_save_id
    Service.save_id('foo', 7003)
    assert_equal '7003', storage.get('service/provider_key:foo/id')
  end

  def test_delete_id
    Service.save_id('foo', 7004)
    Service.delete_id('foo')

    assert_nil storage.get('service/provider_key:foo/id')
  end
end
