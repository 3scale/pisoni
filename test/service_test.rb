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

    Service.delete_by_id(7001, {:force => true})
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
    Service.delete_by_id(7003, {:force => true})

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

    assert_equal '1', Service.get_version(2001)
    service.save
    assert_equal '2', Service.get_version(2001)

    application = Service.load('foo')
    assert_equal '2', Service.get_version(2001)

    Service.delete_by_id(2001, {:force => true})
    assert_nil Service.get_version(2001) 

  end

  def test_load_by_id

    Service.save(:provider_key => 'foo', :id => 7001)

    service = Service.load_by_id(7001)
    assert_equal  'foo', service.provider_key
    assert_equal  true, service.user_registration_required?
    assert_nil    service.default_user_plan_id
    assert_nil    service.default_user_plan_name

    service = Service.load(99999)
    assert_nil  service

    service = Service.load_by_id(99999)
    assert_nil  service

  end

  def test_combinations_of_registration_required_and_default_plans

    assert_raise ServiceRequiresDefaultUserPlan do 
      service = Service.save(:provider_key => 'foo', :id => 7001, :user_registration_required => false)
    end
        
    service = Service.save(:provider_key => 'foo', :id => 7001, :user_registration_required => false, :default_user_plan_id => 1001, :default_user_plan_name => "user_plan_name")
    service = Service.load('foo')
    assert_equal  false, service.user_registration_required?
    assert_equal  '1001', service.default_user_plan_id
    assert_equal  'user_plan_name', service.default_user_plan_name
    Service.delete_by_id(7001, {:force => true})


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

  def test_multiple_services

    assert_equal [], Service.list('foo')

    service1 = Service.save(:provider_key => 'foo', :id => 7001)     
    assert_equal true, service1.default_service?
    assert_equal ["7001"], Service.list('foo')

    service2 = Service.save(:provider_key => 'foo', :id => 7002)
    assert_equal false, service2.default_service?
    assert_equal ["7001", "7002"], Service.list('foo')

    service3 = Service.save(:provider_key => 'foo', :id => 7003)
    assert_equal false, service3.default_service?
    assert_equal ["7001", "7002", "7003"], Service.list('foo')

    Service.delete_by_id(7002)
    assert_equal ["7001", "7003"], Service.list('foo')

    Service.delete_by_id(7003, {:force => true})
    assert_equal ["7001"], Service.list('foo')

    assert_equal "7001", Service.load_id('foo')

    service1 = Service.load('foo')
    service2 = Service.load_by_id(7001)
    assert_not_nil service1
    assert_not_nil service2
    assert_equal service1.id, service2.id

    assert_equal true, service1.default_service?
    assert_equal true, service2.default_service?

    assert_raise ServiceIsDefaultService do 
      Service.delete_by_id(7001)
    end

    Service.delete_by_id(7001, {:force => true})
    assert_nil Service.load('foo')  


  end

  def test_multiple_service_load
    
    Service.save(:provider_key => 'foo', :id => 7001)     
    Service.save(:provider_key => 'foo', :id => 7002)
    Service.save(:provider_key => 'foo', :id => 7003)

    service3 = Service.load_by_id(7003)
    service2 = Service.load_by_id(7002)
    service1 = Service.load_by_id(7001)
    assert_equal Service.load('foo').id.to_i, 7001

    assert_equal true, service1.default_service?
    assert_equal false, service2.default_service?
    assert_equal false, service3.default_service?

  end

  def test_change_defaults

    Service.save(:provider_key => 'foo', :id => 7001)     
    Service.save(:provider_key => 'foo', :id => 7002)

    service1 = Service.load_by_id(7001)
    service2 = Service.load_by_id(7002)

    assert_equal true, service1.default_service?
    assert_equal false, service2.default_service?

    assert_raise ServiceIsDefaultService do
      Service.delete_by_id(7001)
    end

    v1_0 = Service.get_version(7001)
    v2_0 = Service.get_version(7002)

    assert_equal '7001', Service.load_id('foo')
    assert_equal '7001', service2.make_default_service
    assert_equal '7002', Service.load_id('foo')


    service1 = Service.load_by_id(7001)
    service2 = Service.load_by_id(7002)
    
    assert_equal false, service1.default_service?
    assert_equal true, service2.default_service?

    assert_equal ["7001","7002"], Service.list('foo')
    
    v1_1 = Service.get_version(7001)
    v2_1 = Service.get_version(7002)

    assert_equal v1_0.to_i+1 , v1_1.to_i
    assert_equal v2_0.to_i+1 , v2_1.to_i

    assert_raise ServiceIsDefaultService do 
      Service.delete_by_id(7002)
    end
    Service.delete_by_id(7001)
    


  end


end
