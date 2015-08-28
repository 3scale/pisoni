require_relative './spec_helper'

module ThreeScale
  module Core
    describe UsageLimit do
      before do
        @sample_period_limits = { eternity: 10_000_000, year: 2_000_000, month: 700_000,
                                  week: 300_000, hour: 5_000, minute: 200 }
        @sample_period_limits.each do |p, l|
          UsageLimit.save(service_id: '2001', plan_id: '3001',
                          metric_id: '4001', p => l)
        end
      end

      it 'saves a UsageLimit' do
        daylimit = 50

        UsageLimit.save(service_id: '2001', plan_id: '3001', metric_id: '4002', day: daylimit)
        UsageLimit.load_value('2001', '3001', '4002', :day).must_equal daylimit
      end

      it 'correctly loads all periods of a UsageLimit' do
        @sample_period_limits.keys.map do |p|
          [p, UsageLimit.load_value('2001', '3001', '4001', p)]
        end.to_h.must_equal @sample_period_limits
      end

      it 'returns zero for a period without limit' do
        period = (UsageLimit::PERIODS - @sample_period_limits.keys).sample
        UsageLimit.load_value('2001', '3001', '4001', period).must_be_nil
      end

      it 'deletes a given period from a sample usage limit' do
        UsageLimit.delete('2001', '3001', '4001', :week)

        UsageLimit.load_value('2001', '3001', '4001', :week).must_be_nil
      end

      it 'raises if multiple periods are specified on .save' do
        proc do
          UsageLimit.save(service_id: '2001', plan_id: '3001', metric_id: '4002', day: 5, week: 10)
        end.must_raise UsageLimitInvalidPeriods
      end

      it 'raises if no periods are specified on .save' do
        proc do
          UsageLimit.save(service_id: '2001', plan_id: '3001', metric_id: '4002')
        end.must_raise UsageLimitInvalidPeriods
      end
    end
  end
end
