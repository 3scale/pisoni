require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ServiceTest < Test::Unit::TestCase
  def setup
    storage.flushdb
  end

  def test_save
    Service.save(:provider_key => 'foo', :id => 7001, :referrer_filters_required => true)
    assert_equal '7001', storage.get('service/provider_key:foo/id')
    assert_equal '1',    storage.get('service/id:7001/referrer_filters_required')
    assert_nil           storage.get('service/id:7001/backend_version')
    assert_equal '1',    storage.get('service/id:7001/user_registration_required')

  end

  def test_save_with_backend_version
    Service.save(:provider_key => 'foo', :id => 7001, :backend_version => 'oauth')
    assert_equal '7001', storage.get('service/provider_key:foo/id')
    assert_equal 'oauth',storage.get('service/id:7001/backend_version')
  end

  def test_save_with_user_registration_required
    
    Service.save(:provider_key => 'foo', :id => 7001)
    assert_equal '7001',  storage.get('service/provider_key:foo/id')
    assert_equal '1',     storage.get('service/id:7001/user_registration_required')

    service = Service.load('foo')
    assert_equal  true,  service.user_registration_required?
    service.save
    service = Service.load('foo')
    assert_equal  true,  service.user_registration_required?

    Service.delete('foo')
    assert_nil            storage.get('service/id:7001/user_registration_required')
    
  end



  def test_load
    storage.set('service/provider_key:foo/id', '7001')
    storage.set('service/id:7001/referrer_filters_required', '1')

    service = Service.load('foo')

    assert_not_nil service
    assert_equal 'foo',  service.provider_key
    assert_equal '7001', service.id
    assert service.referrer_filters_required?
    assert_nil service.backend_version
  end

  def test_load_with_backend_version
    storage.set('service/provider_key:foo/id', '7001')
    storage.set('service/id:7001/backend_version', 'oauth')

    service = Service.load('foo')

    assert_not_nil service
    assert_equal 'foo',  service.provider_key
    assert_equal '7001', service.id
    assert_equal 'oauth',service.backend_version
  end

  def test_delete
    Service.save(:provider_key => 'foo', :id => 7003, :referrer_filters_required => true, :backend_version => 'oauth')
    Service.delete('foo')

    assert_nil storage.get('service/provider_key:foo/id')
    assert_nil storage.get('service/id:7003/referrer_filters_required')
    assert_nil storage.get('service/id:7003/backend_version')
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

  def test_versions

    assert !Service.exists?('foo')

    service = Service.save(:provider_key => 'foo', :id => 2001)

    assert_equal '1', Service.get_version('2001')
    service.save
    assert_equal '2', Service.get_version('2001')

    application = Service.load('foo')
    assert_equal '2', Service.get_version('2001')

    Service.delete('foo')
    assert_nil Service.get_version('2001') 

  end

  def test_load_by_id

    Service.save(:provider_key => 'foo', :id => 7001)

    service = Service.load_by_id("7001")
    assert_equal  'foo', service.provider_key
    assert_equal  true, service.user_registration_required?
    assert_nil    service.default_user_plan_id
    assert_nil    service.default_user_plan_name

    #service = Service.load_by_id("99999")
    service = Service.load("99999")
    assert_nil  service

    service = Service.load_by_id("99999")
    assert_nil  service

  end

  def test_combinations_of_registration_required_and_default_plans

    assert_raise RuntimeError do 
      service = Service.save(:provider_key => 'foo', :id => 7001, :user_registration_required => false)
    end
        
    service = Service.save(:provider_key => 'foo', :id => 7001, :user_registration_required => false, :default_user_plan_id => "1001", :default_user_plan_name => "user_plan_name")
    service = Service.load('foo')
    assert_equal  false, service.user_registration_required?
    assert_equal  "1001", service.default_user_plan_id
    assert_equal  "user_plan_name", service.default_user_plan_name
    Service.delete('foo')


    service = Service.save(:provider_key => 'foo', :id => 7001)
    assert_equal  true, service.user_registration_required?
    assert_nil    service.default_user_plan_id
    assert_nil    service.default_user_plan_name

    service.default_user_plan_id="1001"
    service.default_user_plan_name="user_plan_name"
    service.save

    service = Service.load('foo')
    assert_equal  true, service.user_registration_required?
    assert_equal  "1001", service.default_user_plan_id
    assert_equal  "user_plan_name", service.default_user_plan_name
    
  end


end
