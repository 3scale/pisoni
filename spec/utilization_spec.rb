require_relative './spec_helper'

module ThreeScale
  module Core
    describe Utilization do
      let(:service_id) { '1001' }
      let(:non_existing_service_id) { service_id.to_i.succ.to_s }
      let(:provider_key) { 'foo' }

      let(:app_id) { '2001' }
      let(:non_existing_app_id) { app_id.to_i.succ.to_s }

      let(:plan) { { id: '3001', name: 'test_plan' } }

      let(:metric) { { service_id: service_id, id: '4001', name: 'hits' } }

      let(:app) do
        { service_id: service_id,
          id: app_id,
          state: :active,
          plan_id: plan[:id],
          plan_name: plan[:name] }
      end

      let(:usage_limits) do
        [{ service_id: service_id,
           plan_id: plan[:id],
           metric_id: metric[:id],
           day: 100 },
         { service_id: service_id,
           plan_id: plan[:id],
           metric_id: metric[:id],
           month: 200 }]
      end

      describe '.load' do
        before do
          Service.delete_by_id!(service_id)
          Service.save!(provider_key: provider_key, id: service_id)

          Application.delete(service_id, app_id)
          Application.save(app)

          Metric.delete(service_id, metric[:id])
          Metric.save(metric)

          UsageLimit::PERIODS.each do |period|
            usage_limits.each do |limit|
              UsageLimit.delete(limit[:service_id],
                                limit[:plan_id],
                                limit[:metric_id],
                                period)
            end
          end
          usage_limits.each { |limit| UsageLimit.save(limit) }

          Transaction.delete_all(service_id)
        end

        # This is a basic test that only checks the structure of the response.
        # The reason is that we do not have an endpoint in backend that allows
        # us to save utilization transactions. We could have added one, but we
        # decided it was not worth it because of two reasons:
        # 1) The method to add transactions manually in backend would have been
        # a bit complex because script/test_external does not run any workers,
        # and transactions are saved creating tasks executed by workers.
        # 2) There is no way in backend to delete utilization transactions, so
        # even if we added a method to save them, we would not be able to know
        # how many are saved in the system to perform a proper test.
        describe 'with app that has daily and monthly limits for a metric' do
          subject { Utilization.load(service_id, app_id) }

          it 'has the correct number of reports' do
            # We could think that subject.size should equal usage_limits.size.
            # However, we could have other limits previously saved in the
            # backend. Therefore, we can only be sure that the size is equal or
            # greater than usage_limits.size
            subject.size.must_be :>=, usage_limits.size
            subject.total.must_be :>=, usage_limits.size
          end

          it 'has reports with all their attributes set' do
            subject.each do |report|
              Utilization.attributes.each do |utilization_attr|
                report.send(utilization_attr).wont_be_nil
              end
            end
          end

          it 'has reports with fields that have the correct type' do
            example_report = subject.first
            example_report.period.must_be_kind_of String
            example_report.metric_name.must_be_kind_of String
            example_report.max_value.must_be_kind_of Numeric
            example_report.current_value.must_be_kind_of Numeric
          end
        end

        describe 'with an invalid service ID' do
          it 'raises ServiceNotFound exception' do
            lambda do
              Utilization.load(non_existing_service_id, app_id)
            end.must_raise ServiceNotFound
          end
        end

        describe 'with an invalid application ID' do
          it 'raises ApplicationNotFound exception' do
            lambda do
              Utilization.load(service_id, non_existing_app_id)
            end.must_raise ApplicationNotFound
          end
        end
      end
    end
  end
end
