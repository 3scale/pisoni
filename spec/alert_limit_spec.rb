require_relative './spec_helper'
module ThreeScale
  module Core
    describe AlertLimit do
      describe '.load_all' do
        describe 'when there are alert limits' do
          let(:service_id) { 100 }
          let(:values)     { [50, 100] }
          before do
            values.map { |value| AlertLimit.delete(service_id, value) }
            values.map { |value| AlertLimit.save(service_id, value) }
          end

          it 'returns a list of alert limits' do
            alert_limits = AlertLimit.load_all(service_id)

            alert_limits.size.must_equal 2
            alert_limits.map(&:value).must_equal values
          end
        end

        describe 'when there are no alert limits' do
          let(:service_id) { 200 }

          it 'returns an empty list' do
            AlertLimit.load_all(service_id).must_equal []
          end
        end
      end

      describe '.save' do
        let(:service_id) { 500 }
        let(:value)      { 100 }

        before do
          AlertLimit.delete(service_id, value)
        end

        it 'returns a AlertLimit object' do
          alert_limit = AlertLimit.save(service_id, value)

          alert_limit.must_be_kind_of AlertLimit
          alert_limit.value.must_equal value
        end
      end

      describe '.delete' do
        describe 'with an existing alert limit' do
          let(:service_id) { 300 }
          let(:value)      { 50 }

          before do
            AlertLimit.save(service_id, value)
          end

          it 'returns true' do
            AlertLimit.delete(service_id, value).must_equal true
          end
        end

        describe 'with a non-existing alert limit' do
          let(:service_id) { 300 }
          let(:value)      { 75  }

          it 'returns true' do
            AlertLimit.delete(service_id, value).must_equal false
          end
        end
      end
    end
  end
end
