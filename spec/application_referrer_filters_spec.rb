require_relative './spec_helper'
module ThreeScale
  module Core
    describe ApplicationReferrerFilter do
      let(:service_id) { 10 }
      let(:app_id)     { 100 }

      before do
        cleanup_application_fixtures
        create_sample_app
      end

      describe '.load_all' do
        describe 'Getting all referrer filters' do
          let(:values)     { ["foo", "bar"] }

          before do
            values.map { |value| ApplicationReferrerFilter.save service_id, app_id, value }
          end

          it 'returns a sorted list of filters' do
            filters = ApplicationReferrerFilter.load_all service_id, app_id

            filters.must_equal values.sort
          end
        end

        describe 'when there are no referrer filters' do
          it 'returns an empty list' do
            ApplicationReferrerFilter.load_all(service_id, app_id).must_equal []
          end
        end
      end

      describe '.save' do
        let(:value) { "doopah" }

        it 'returns an ApplicationReferrerFilter object' do
          filter = ApplicationReferrerFilter.save(service_id, app_id, value)
          filter = ApplicationReferrerFilter.load_all(service_id, app_id).must_equal(['doopah'])
        end
      end

      private

      def cleanup_application_fixtures
        ['foo', 'bar', 'doopah'].map do |filter|
          ApplicationReferrerFilter.delete 10, 100, filter
        end
        Application.delete 10, 100
      end

      def create_sample_app
        Application.save service_id: service_id, id: app_id, state: 'suspended',
                         plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                         version: '666'
      end
    end
  end
end
