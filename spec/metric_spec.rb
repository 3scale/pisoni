require_relative './spec_helper'

module ThreeScale
  module Core
    describe Metric do
      describe '.save' do
        before do
          VCR.use_cassette 'delete sample metric' do
            Metric.delete(1001, 2001)
          end
          @metric = VCR.use_cassette 'save sample metric' do
            Metric.save(service_id: 1001, id: 2001, name: 'hits')
          end
        end

        it 'exists' do
          VCR.use_cassette '.save load sample metric' do
            Metric.load(@metric.service_id, @metric.id)
          end.wont_be_nil
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
          new_metric = VCR.use_cassette 'save with an existing metric' do
            Metric.save(service_id: @metric.service_id, id: @metric.id, name: 'rqps')
          end

          new_metric.wont_be_nil
          new_metric.id.must_equal(@metric.id)
          new_metric.service_id.must_equal(@metric.service_id)
          new_metric.name.wont_equal(@metric.name)
          new_metric.name.must_equal 'rqps'

          reloaded_metric = VCR.use_cassette 'reload sample metric after changes' do
            Metric.load(@metric.service_id, @metric.id)
          end
          reloaded_metric.wont_be_nil
          new_metric.name.must_equal(reloaded_metric.name)
        end
      end

      describe '.load' do
        before do
          VCR.use_cassette 'delete sample metric' do
            Metric.delete(1001, 2001)
          end
          VCR.use_cassette 'save sample metric' do
            Metric.save(service_id: 1001, id: 2001, name: 'hits')
          end
        end

        it 'returns a Metric object' do
          VCR.use_cassette 'load sample metric' do
            Metric.load(1001, 2001)
          end.class.must_equal Metric
        end

        it 'parses data from received JSON' do
          metric = VCR.use_cassette 'load sample metric' do
            Metric.load(1001, 2001)
          end

          metric.wont_be_nil
          metric.id.must_equal '2001'
          metric.service_id.must_equal '1001'
          metric.name.must_equal 'hits'
        end

        describe 'with a non-existing service id' do
          it 'returns nil' do
            VCR.use_cassette 'load a metric with a non-existing service' do
              Metric.load(7999, 2001)
            end.must_be_nil
          end
        end

        describe 'with a non-existing id' do
          it 'returns nil' do
            VCR.use_cassette 'load a metric with a non-existing id' do
              Metric.load(1001, 7999)
            end.must_be_nil
          end
        end

      end

      describe '.delete' do
        before do
          VCR.use_cassette 'delete sample metric' do
            Metric.delete(1001, 2001)
          end
          VCR.use_cassette 'save sample metric' do
            Metric.save(service_id: 1001, id: 2001, name: 'hits')
          end
        end

        describe 'with an existing metric' do
          it 'returns true' do
            VCR.use_cassette 'delete existing sample metric' do
              Metric.delete(1001, 2001)
            end.must_equal true
          end

          it 'makes it non-existent' do
            VCR.use_cassette 'delete existing sample metric' do
              Metric.delete(1001, 2001)
            end
            VCR.use_cassette 'load deleted sample metric' do
              Metric.load(1001, 2001)
            end.must_be_nil
          end
        end

        describe 'with a non-existent metric' do
          it 'returns false when using a non-existing service id' do
            VCR.use_cassette 'delete non-existing metric with missing service' do
              Metric.delete(7999, 2001)
            end.must_equal false
          end

          it 'returns false when using a non-existing metric id' do
            VCR.use_cassette 'delete non-existing metric id' do
              Metric.delete(1001, 7999)
            end.must_equal false
          end
        end
      end
    end
  end
end
