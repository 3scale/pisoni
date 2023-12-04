require_relative './spec_helper'
module ThreeScale
  module Core
    describe ApplicationReferrerFilter do
      let(:service_id) { 10 }
      let(:app_id)     { 100 }
      let(:filters) { %w(foo bar doopah) }
      let(:application) do
        { service_id: service_id,
          id: app_id,
          state: 'suspended',
          plan_id: '3066',
          plan_name: 'crappy',
          redirect_url: 'blah' }
      end

      before do
        filters.map do |filter|
          ApplicationReferrerFilter.delete(service_id, app_id, filter)
        end

        Application.delete(service_id, app_id)
        Application.save(application)
      end

      describe '.load_all' do
        describe 'Getting all referrer filters' do
          let(:ref_filters)     { %w(foo bar) }

          before do
            ref_filters.map { |value| ApplicationReferrerFilter.save(service_id, app_id, value) }
          end

          it 'returns a sorted list of filters' do
            filters = ApplicationReferrerFilter.load_all(service_id, app_id)
            filters.must_equal ref_filters.sort
          end
        end

        describe 'when there are no referrer filters' do
          it 'returns an empty list' do
            ApplicationReferrerFilter.load_all(service_id, app_id).must_equal []
          end
        end
      end

      describe '.save' do
        let(:filter) { 'doopah' }

        it 'saves the filter' do
          ApplicationReferrerFilter.save(service_id, app_id, filter)
          ApplicationReferrerFilter.load_all(service_id, app_id).must_equal([filter])
        end
      end
    end
  end
end
