require_relative './spec_helper'

module ThreeScale
  module Core
    describe UsageLimit do
      before do
        @sample_period_limits = { eternity: 10_000_000, year: 2_000_000, month: 700_000,
                                  week: 300_000, hour: 5_000, minute: 200 }
        VCR.use_cassette 'save a sample usage limit' do
          UsageLimit.save({ service_id: '2001', plan_id: '3001', metric_id: '4001' }.
                          merge(@sample_period_limits))
        end
      end

      it 'saves a UsageLimit' do
        daylimit = 50

        VCR.use_cassette 'save a simple usage limit' do
          UsageLimit.save(service_id: '2001', plan_id: '3001', metric_id: '4002', day: daylimit)
        end

        VCR.use_cassette 'load a period from a simple usage limit' do
          UsageLimit.load_value('2001', '3001', '4002', :day)
        end.must_equal daylimit
      end

      it 'correctly loads all periods of a UsageLimit' do
        VCR.use_cassette 'load all periods from the sample usage limit' do
          @sample_period_limits.keys.map do |p|
            [p, UsageLimit.load_value('2001', '3001', '4001', p)]
          end
        end.to_h.must_equal @sample_period_limits
      end

      it 'returns zero for a period without limit' do
        period = (UsageLimit::PERIODS - @sample_period_limits.keys).sample
        VCR.use_cassette 'load an unset period from the sample usage limit' do
          UsageLimit.load_value('2001', '3001', '4001', period)
        end.must_be_nil
      end

      it 'deletes a given period from a sample usage limit' do
        VCR.use_cassette 'delete period from the sample usage limit' do
          UsageLimit.delete('2001', '3001', '4001', :week)
        end

        VCR.use_cassette 'load deleted period from sample usage limit' do
          UsageLimit.load_value('2001', '3001', '4001', :week)
        end.must_be_nil
      end
    end
  end
end
