require_relative './spec_helper'

module ThreeScale
  module Core
    describe Metric do
      describe '.save' do
        before do
          Metric.delete(1001, 2001)
          @metric = Metric.save(service_id: 1001, id: 2001, name: 'hits')
        end

        it 'exists' do
          Metric.load(@metric.service_id, @metric.id).wont_be_nil
        end

        it 'returns a Metric object' do
          @metric.must_be_kind_of Metric
        end

        it 'returns a Metric object with correct fields' do
          @metric.service_id.must_equal '1001'
          @metric.id.must_equal '2001'
          @metric.name.must_equal 'hits'
          @metric.parent_id.must_be_nil
        end

        it 'modifies a Metric when saving an existing one' do
          new_metric = Metric.save(service_id: @metric.service_id, id: @metric.id, name: 'rqps')

          new_metric.wont_be_nil
          new_metric.id.must_equal(@metric.id)
          new_metric.service_id.must_equal(@metric.service_id)
          new_metric.name.wont_equal(@metric.name)
          new_metric.name.must_equal 'rqps'

          reloaded_metric = Metric.load(@metric.service_id, @metric.id)

          reloaded_metric.wont_be_nil
          new_metric.name.must_equal(reloaded_metric.name)
        end

        it 'raises a client-side error when missing mandatory attributes' do
          {service_id: 9000, foo: 'bar', id: 6077}.each_cons(2) do |attrs|
            attrs = attrs.to_h
            # note missing service_id, id
            attrs.merge!(name: 'somename')
            lambda do
              Metric.save(attrs)
            end.must_raise KeyError # minitest wont catch parent exceptions :/
          end
        end
      end

      describe '.load' do
        before do
          Metric.delete(1001, 2001)
          Metric.save(service_id: 1001, id: 2001, name: 'hits')
        end

        it 'returns a Metric object' do
          Metric.load(1001, 2001).class.must_equal Metric
        end

        it 'parses data from received JSON' do
          metric = Metric.load(1001, 2001)

          metric.wont_be_nil
          metric.id.must_equal '2001'
          metric.service_id.must_equal '1001'
          metric.name.must_equal 'hits'
        end

        describe 'with a non-existing service id' do
          it 'returns nil' do
            Metric.load(7999, 2001).must_be_nil
          end
        end

        describe 'with a non-existing id' do
          it 'returns nil' do
            Metric.load(1001, 7999).must_be_nil
          end
        end
      end

      describe '.delete' do
        before do
          Metric.delete(1001, 2001)
          Metric.save(service_id: 1001, id: 2001, name: 'hits')
        end

        describe 'with an existing metric' do
          it 'returns true' do
            Metric.delete(1001, 2001).must_equal true
          end

          it 'makes it non-existent' do
            Metric.delete(1001, 2001)
            Metric.load(1001, 2001).must_be_nil
          end
        end

        describe 'with a non-existent metric' do
          it 'returns false when using a non-existing service id' do
            Metric.delete(7999, 2001).must_equal false
          end

          it 'returns false when using a non-existing metric id' do
            Metric.delete(1001, 7999).must_equal false
          end
        end
      end
    end
  end
end
