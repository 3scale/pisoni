require File.dirname(__FILE__) + '/test_helper'

class ContractTest < Test::Unit::TestCase
  def test_save
    storage.expects(:set).with('contract/service_id:2001/user_key:foo/id', '8010')
    storage.expects(:set).with('contract/service_id:2001/user_key:foo/state', 'live')
    storage.expects(:set).with('contract/service_id:2001/user_key:foo/plan_id', '3001')
    storage.expects(:set).with('contract/service_id:2001/user_key:foo/plan_name', 'awesome')

    Contract.save(:service_id => '2001',
                  :user_key   => 'foo',
                  :id         => '8010',
                  :state      => :live,
                  :plan_id    => '3001',
                  :plan_name  => 'awesome')
  end

  def test_load
    storage.stubs(:mget).
      with('contract/service_id:2001/user_key:foo/id',
           'contract/service_id:2001/user_key:foo/state',
           'contract/service_id:2001/user_key:foo/plan_id',
           'contract/service_id:2001/user_key:foo/plan_name').
      returns(['8011', 'suspended', '3066', 'crappy'])
                             
    contract = Contract.load(2001, 'foo')

    assert_equal '8011',     contract.id
    assert_equal :suspended, contract.state
    assert_equal '3066',     contract.plan_id
    assert_equal 'crappy',   contract.plan_name
  end
end
