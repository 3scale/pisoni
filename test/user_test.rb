require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class UserTest < Test::Unit::TestCase

  def setup
    storage.flushdb
  end

  def test_create_user_errors
    VCR.use_cassette 'test/user creation errors' do
      service = Service.save! :provider_key => 'foo', :id => 7001001

      assert_raise ServiceRequiresRegisteredUser do
        ## failure because the service needs registered users
        User.load_or_create!(service, 'username1')
      end

      assert_raise UserRequiresDefinedPlan do
        ## failure because user requires a defined plan
        User.save!(:username => 'username', :service_id => '7001001')
      end

      assert_raise UserRequiresUsername do
        User.save!(:service_id => '7001')
      end

      assert_raise UserRequiresValidService do
        User.save!(:username => 'username', :service_id => '7001001001')
      end
    end
  end

  def test_create_user_successful_service_require_registered_users
    VCR.use_cassette 'test/user successful creation - require registration' do
      service = Service.save!(provider_key: 'foo', id: '7002')
      User.save! username: 'username', service_id: '7002', plan_id: '1001',
        plan_name: 'planname'
      user = User.load(service.id, 'username')

      assert_equal true, user.active?
      assert_equal 'username', user.username
      assert_equal 'planname', user.plan_name
      assert_equal '1001', user.plan_id
      assert_equal '7002', user.service_id

      User.delete! service.id, user.username

      assert_raise ServiceRequiresRegisteredUser do
        ## failure trying to load a user who does not exist and the service does not support open loop
        user = User.load_or_create!(service, 'username')
      end
    end

  end

  def test_create_user_successful_service_not_require_registered_users
    VCR.use_cassette 'test/user successful creation - not require registration' do
      service = Service.save!(provider_key: 'foo', id: '7001',
        user_registration_required: false, default_user_plan_name: 'planname',
        default_user_plan_id: '1001')

      names = %w(username0 username1 username2 username3 username4 username5)
      names.each_with_index do |username, idx|
        user = User.load_or_create!(service, username)

        assert_equal true, user.active?
        assert_equal username, user.username
        assert_equal service.default_user_plan_name, user.plan_name
        assert_equal service.default_user_plan_id, user.plan_id
        assert_equal service.id, user.service_id
      end
    end
  end
end
