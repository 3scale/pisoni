require File.dirname(__FILE__) + '/test_helper'

class MetricTest < Test::Unit::TestCase
  def test_save
    storage.expects(:set).with("metric/service_id:1001/name:hits/id", 2001)
    storage.expects(:set).with("metric/service_id:1001/id:2001/name", 'hits')
    storage.expects(:sadd).with("metrics/service_id:1001/ids", 2001)
    
    storage.expects(:set).with("metric/service_id:1001/id:2001/parent_id", anything).never

    metric = Metric.new(:service_id => 1001, :id => 2001, :name => 'hits')
    metric.save
  end

  def test_save_with_children
    storage.expects(:set).with("metric/service_id:1001/name:hits/id", 2001)
    storage.expects(:set).with("metric/service_id:1001/id:2001/name", 'hits')
    storage.expects(:sadd).with("metrics/service_id:1001/ids", 2001)
    
    storage.expects(:set).with("metric/service_id:1001/name:search_queries/id", 2002)
    storage.expects(:set).with("metric/service_id:1001/id:2002/name", 'search_queries')
    storage.expects(:sadd).with("metrics/service_id:1001/ids", 2002)
    storage.expects(:set).with("metric/service_id:1001/id:2002/parent_id", 2001)

    metric = Metric.new(:service_id => 1001, :id => 2001, :name => 'hits')
    metric.children << Metric.new(:id => 2002, :name => 'search_queries')
    metric.save
  end
end
