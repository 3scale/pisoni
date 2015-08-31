require_relative './spec_helper'
module ThreeScale
  module Core
    describe ApplicationKey do
      describe '.load_all' do
        describe 'when there are application keys' do
          let(:service_id) { 100 }
          let(:app_id)     { 2001 }
          let(:values)     { ["foo", "bar"] }
          before do
            values.map { |value| ApplicationKey.delete(service_id, app_id, value) }

            # note that version: 666 should not be saved!
            Application.save service_id: service_id, id: app_id, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                             version: '666'

            values.map { |value| ApplicationKey.save(service_id, app_id, value) }
          end

          it 'returns a list of application keys' do
            application_keys = ApplicationKey.load_all(service_id, app_id)

            application_keys.size.must_equal 2
            application_keys.map(&:value).sort.must_equal values.sort
          end
        end

        describe 'when there are no application keys' do
          let(:service_id) { 200 }
          let(:app_id)     { 300 }

          before do
            # note that version: 666 should not be saved!
            Application.save service_id: service_id, id: app_id, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                             version: '666'
          end

          it 'returns an empty list' do
            ApplicationKey.load_all(service_id, app_id).must_equal []
          end
        end
      end

      describe '.save' do
        let(:service_id) { 500 }
        let(:app_id)     { 500 }
        let(:value)      { "foobar" }

        before do
          ApplicationKey.delete(service_id, app_id, value)

          # note that version: 666 should not be saved!
          Application.save service_id: service_id, id: app_id, state: 'suspended',
                           plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                           version: '666'
        end

        it 'returns an ApplicationKey object' do
          application_key = ApplicationKey.save(service_id, app_id, value)

          application_key.must_be_kind_of ApplicationKey
          application_key.value.must_equal value
        end
      end

      describe '.delete' do
        describe 'with an existing application key' do
          let(:service_id) { 300 }
          let(:app_id)     { 200 }
          let(:value)      { "foo" }

          before do
            # note that version: 666 should not be saved!
            Application.save service_id: service_id, id: app_id, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                             version: '666'

            ApplicationKey.save(service_id, app_id, value)
          end

          it 'returns true' do
            ApplicationKey.delete(service_id, app_id, value).must_equal true
          end
        end

        describe 'with a non-existing application key' do
          let(:service_id) { 300 }
          let(:app_id)     { 500 }
          let(:value)      { "nonexistingkey" }

          before do
            # note that version: 666 should not be saved!
            Application.save service_id: service_id, id: app_id, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                             version: '666'
          end

          it 'returns true' do
            ApplicationKey.delete(service_id, app_id, value).must_equal false
          end
        end
      end
    end
  end
end