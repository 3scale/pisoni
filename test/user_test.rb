require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class UserTest < Test::Unit::TestCase
  
  def setup
    storage.flushdb
  end

  def test_create_user_errors

    service = Service.save!(:provider_key => 'foo', :id => 7001)

    assert_raise ServiceRequiresRegisteredUser do
      ## failure because the service needs registered users
      User.load(service,'username1')
    end
  
    assert_raise UserRequiresDefinedPlan do
      ## failure because user requires a defined plan
      User.save(:username => 'username', :service_id => '7001')
    end

    assert_raise UserRequiresUsername do
      User.save(:service_id => '7001')
    end

    assert_raise UserRequiresValidService do
      User.save(:username => 'username', :service_id => '7001000')
    end

  end


  def test_create_user_successful_service_require_registered_users

    service = Service.save!(:provider_key => 'foo', :id => '7001')
    User.save(:username => 'username', :service_id => '7001', :plan_id => '1001', :plan_name => 'planname')
  
    user = User.load(service, 'username')

    assert_equal  true, user.active?
    assert_equal  'username', user.username
    assert_equal  'planname', user.plan_name
    assert_equal  '1001', user.plan_id
    assert_equal  '7001', user.service_id

    User.delete(service.id,user.username)

    assert_raise ServiceRequiresRegisteredUser do
      ## failure trying to load a user who does not exist and the service does not support open loop
      user = User.load(service,'username')
    end
 
  end

  def test_create_user_successful_service_not_require_registered_users

    service = Service.save!(:provider_key => 'foo', :id => '7001', :user_registration_required => false, :default_user_plan_name => 'planname', :default_user_plan_id => '1001')

    v = ['username0','username1','username2','username3','username4','username5']

    version_1 = Service.get_version(service.id)    
    assert_equal '1', version_1

    cont=1
    v.each do |username|
      assert_equal  false, service.user_exists?(username)

      user = User.load(service,username)

      assert_equal  true, user.active?
      assert_equal  username, user.username
      assert_equal  service.default_user_plan_name, user.plan_name
      assert_equal  service.default_user_plan_id, user.plan_id
      assert_equal  service.id, user.service_id
      
      assert_equal  true, service.user_exists?(user.username)
      assert_equal  cont, service.user_size
 
      cont=cont+1
    end

    version_2 = Service.get_version(service.id)
    assert_equal "#{(1+v.size)}", version_2

     
  end

  def test_create_repeated_users

    service = Service.save!(:provider_key => 'foo', :id => '7001', :user_registration_required => false, :default_user_plan_name => 'planname', :default_user_plan_id => '1001')

    user = User.load(service,'username')

    val = Service.get_version(service.id)

    3.times do |i|

      user = User.load(service,'username')
      assert_equal  1, service.user_size
      assert_equal val, Service.get_version(service.id)
 
    end

  end


  def test_create_delete_users

    service = Service.save!(:provider_key => 'foo', :id => '7001', :user_registration_required => false, :default_user_plan_name => 'planname', :default_user_plan_id => '1001')

    user = User.load(service,'username')
    user = User.load(service,'username_repeated')
    user = User.load(service,'username_repeated')

    version = Service.get_version(service.id)

    assert_equal  2, service.user_size 
    User.delete(service.id,'username')
    assert_equal  1, service.user_size
    User.delete(service.id,'username_repeated')   
    assert_equal  0, service.user_size

    assert_equal  (version.to_i + 2).to_s, Service.get_version(service.id)     


  end
  
  def test_versions

    service = Service.save!(:provider_key => 'foo', :id => '7001', :user_registration_required => false, :default_user_plan_name => 'planname', :default_user_plan_id => '1001')

    user = User.load(service,'username')
    assert_equal '1', User.get_version(service.id,'username')

    user.plan_id = '1002'
    user.save
    assert_equal '2', User.get_version(service.id,'username')

    user = User.load(service,'username')
    assert_equal '1002', user.plan_id
    assert_equal '2', User.get_version(service.id,'username')

    assert_equal '3', User.incr_version(service.id,'username')

    assert_equal '1', User.incr_version('foo','bla')
    assert_equal '1', User.incr_version(service.id,'bla')

  end

 



end
