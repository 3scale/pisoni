require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ApplicationTest < Test::Unit::TestCase
  def setup
    storage.flushdb
  end

  def test_save
    
    assert_equal [],  storage.smembers('service_id:2001/applications')
        
    Application.save(:service_id => '2001',
                     :id         => '8010',
                     :state      => :active,
                     :plan_id    => '3001',
                     :plan_name  => 'awesome',
                     :redirect_url => 'bla')
    
    assert_equal 'active',  storage.get('application/service_id:2001/id:8010/state')
    assert_equal '3001',    storage.get('application/service_id:2001/id:8010/plan_id')
    assert_equal 'awesome', storage.get('application/service_id:2001/id:8010/plan_name')
    assert_equal 'bla',     storage.get('application/service_id:2001/id:8010/redirect_url')
    assert_equal '1',       storage.get('application/service_id:2001/id:8010/version')    

    assert_equal ['8010'],  storage.smembers('service_id:2001/applications')
    
    Application.save(:service_id => '2001',
                     :id         => '8011',
                     :state      => :active,
                     :plan_id    => '3001',
                     :plan_name  => 'awesome',
                     :redirect_url => 'bla')

    assert_equal ['8010','8011'].sort,  storage.smembers('service_id:2001/applications').sort

  end

  def test_save_with_explicit_version
    Application.save(:service_id => '2001',
                     :id         => '8010',
                     :state      => :active,
                     :plan_id    => '3001',
                     :plan_name  => 'awesome',
                     :redirect_url => 'bla')
    
    assert_equal 'active',  storage.get('application/service_id:2001/id:8010/state')
    assert_equal '3001',    storage.get('application/service_id:2001/id:8010/plan_id')
    assert_equal 'awesome', storage.get('application/service_id:2001/id:8010/plan_name')
    assert_equal 'bla',     storage.get('application/service_id:2001/id:8010/redirect_url')
    assert_equal '1',       storage.get('application/service_id:2001/id:8010/version')    
  end



  def test_save_returns_the_new_application
    application = Application.save(:service_id => '2001',
                                   :id         => '8010',
                                   :state      => :active,
                                   :plan_id    => '3001',
                                   :plan_name  => 'awesome',
                                   :redirect_url => 'bla')
    
    assert_instance_of Application, application
    assert_equal '2001',    application.service_id
    assert_equal '8010',    application.id
    assert_equal :active,   application.state
    assert_equal '3001',    application.plan_id
    assert_equal 'awesome', application.plan_name
    assert_equal 'bla',     application.redirect_url
    assert_equal '1',       Application.get_version('2001','8010')
  end

  def test_load
    storage.set('application/service_id:2001/id:8011/state', 'suspended')
    storage.set('application/service_id:2001/id:8011/plan_id', '3066')
    storage.set('application/service_id:2001/id:8011/plan_name', 'crappy')
    storage.set('application/service_id:2001/id:8011/redirect_url', 'bla')
    storage.set('application/service_id:2001/id:8011/version', '666')
                             
    application = Application.load('2001', '8011')

    assert_equal '8011',     application.id
    assert_equal :suspended, application.state
    assert_equal '3066',     application.plan_id
    assert_equal 'crappy',   application.plan_name
    assert_equal 'bla',      application.redirect_url
    assert_equal '666',      Application.get_version('2001','8011')
  end


  def test_load_works_even_for_application_without_plan
    storage.set('application/service_id:2001/id:8011/state', 'suspended')
                             
    application = Application.load('2001', '8011')

    assert_equal '8011',     application.id
    assert_equal :suspended, application.state
    assert_nil               application.plan_id
    assert_nil               application.plan_name
    assert_nil               application.redirect_url
    assert_equal '1',        Application.get_version('2001','8011')

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
  
  def test_failure_when_user_or_app_id_is_blank
    Application.save(:service_id => '2001',
                      :id         => '8012',
                      :state      => :active)

    assert Application.exists?('2001', '8012')
     
    assert_raise ApplicationHasInconsistentData do
      Application.save_id_by_key('2001', '', '8012')
    end

    assert_raise ApplicationHasInconsistentData do
      Application.save_id_by_key('2001', nil, '8012')
    end
    
    assert_raise ApplicationHasInconsistentData do
      Application.save_id_by_key('2001', 'foobar', '')
    end
    
    Application.save_id_by_key('2001', 'foobar', '8022')
    assert_equal '8022', storage.get('application/service_id:2001/key:foobar/id')   
  end

  def test_save_id_by_key
    Application.save_id_by_key('2001', 'foobar', '8022')
    assert_equal '8022', storage.get('application/service_id:2001/key:foobar/id')
  end

  def test_load_id_by_key
    storage.set('application/service_id:2001/key:foobar/id', '8077')
    assert_equal '8077', Application.load_id_by_key('2001', 'foobar')
  end

  def test_delete_id_by_key
    storage.set('application/service_id:2001/key:foobar/id', '8077')

    Application.delete_id_by_key('2001', 'foobar')
    assert_nil storage.get('application/service_id:2001/key:foobar/id')
  end

  def test_versions

    assert !Application.exists?('2001', '8012')

    application = Application.save(:service_id => '2001',
                     :id         => '8012',
                     :state      => :active,
                     :plan_id    => '3002',
                     :plan_name  => 'cool')

    assert_equal '1', Application.get_version('2001','8012')
    application.save
    assert_equal '2', Application.get_version('2001','8012')

    application = Application.load('2001', '8012')
    assert_equal '2', Application.get_version('2001','8012')
    
    assert_equal ['8012'],  storage.smembers('service_id:2001/applications')

    Application.delete(2001, 8012)
    assert_nil Application.get_version('2001','8012')
    
    assert_equal [],  storage.smembers('service_id:2001/applications')

  end

end
