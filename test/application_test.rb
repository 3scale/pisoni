require File.dirname(__FILE__) + '/test_helper'

class ApplicationTest < Test::Unit::TestCase
  def setup
    storage.flushdb
  end

  def test_save
    Application.save(:service_id => '2001',
                     :id         => '8010',
                     :state      => :active,
                     :plan_id    => '3001',
                     :plan_name  => 'awesome')
    
    assert_equal 'active',  storage.get('application/service_id:2001/id:8010/state')
    assert_equal '3001',    storage.get('application/service_id:2001/id:8010/plan_id')
    assert_equal 'awesome', storage.get('application/service_id:2001/id:8010/plan_name')
  end

  def test_save_returns_the_new_application
    application = Application.save(:service_id => '2001',
                                   :id         => '8010',
                                   :state      => :active,
                                   :plan_id    => '3001',
                                   :plan_name  => 'awesome')
    
    assert_instance_of Application, application
    assert_equal '2001',    application.service_id
    assert_equal '8010',    application.id
    assert_equal :active,   application.state
    assert_equal '3001',    application.plan_id
    assert_equal 'awesome', application.plan_name
  end

  def test_load
    storage.set('application/service_id:2001/id:8011/state', 'suspended')
    storage.set('application/service_id:2001/id:8011/plan_id', '3066')
    storage.set('application/service_id:2001/id:8011/plan_name', 'crappy')
                             
    application = Application.load('2001', '8011')

    assert_equal '8011',     application.id
    assert_equal :suspended, application.state
    assert_equal '3066',     application.plan_id
    assert_equal 'crappy',   application.plan_name
  end

  def test_load_works_even_for_application_without_plan
    storage.set('application/service_id:2001/id:8011/state', 'suspended')
                             
    application = Application.load('2001', '8011')

    assert_equal '8011',     application.id
    assert_equal :suspended, application.state
    assert_nil               application.plan_id
    assert_nil               application.plan_name
  end

  def test_load_returns_nil_if_application_is_not_found
    assert_nil Application.load(2001, 'boo')
  end

  def test_delete
    Application.save(:service_id => '2001',
                     :id         => '8011',
                     :state      => :active,
                     :plan_id    => '3001',
                     :plan_name  => 'lame')

    Application.delete(2001, 8011)
    assert_nil Application.load(2001, 8011)
  end

  def test_exists
    assert !Application.exists?('2001', '8012')

    Application.save(:service_id => '2001',
                     :id         => '8012',
                     :state      => :active,
                     :plan_id    => '3002',
                     :plan_name  => 'cool')
    
    assert Application.exists?('2001', '8012')
  end

  def test_exists_returns_true_even_for_application_without_plan
    Application.save(:service_id => '2001',
                     :id         => '8012',
                     :state      => :active)
    
    assert Application.exists?('2001', '8012')
  end

  def test_save_id_by_user_key
    Application.save_id_by_user_key('2001', 'foobar', '8022')
    assert_equal '8022', storage.get('application/service_id:2001/user_key:foobar/id')
  end

  def test_load_id_by_user_key
    storage.set('application/service_id:2001/user_key:foobar/id', '8077')
    assert_equal '8077', Application.load_id_by_user_key('2001', 'foobar')
  end

  def test_delete_id_by_user_key
    storage.set('application/service_id:2001/user_key:foobar/id', '8077')

    Application.delete_id_by_user_key('2001', 'foobar')
    assert_nil storage.get('application/service_id:2001/user_key:foobar/id')
  end
end
