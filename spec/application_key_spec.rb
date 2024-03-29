require_relative './spec_helper'
module ThreeScale
  module Core
    describe ApplicationKey do
      describe '.load_all' do
        describe 'when there are application keys' do
          let(:service_id) { 100 }
          let(:app_id)     { 2001 }
          let(:keys)     { %w[foo bar] }
          before do
            keys.map { |key| ApplicationKey.delete(service_id, app_id, key) }

            Application.save service_id: service_id, id: app_id, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'

            keys.map { |key| ApplicationKey.save(service_id, app_id, key) }
          end

          it 'returns a list of application keys' do
            application_keys = ApplicationKey.load_all(service_id, app_id)

            application_keys.size.must_equal 2
            application_keys.map(&:value).sort.must_equal keys.sort
          end
        end

        describe 'when there are no application keys' do
          let(:service_id) { 200 }
          let(:app_id)     { 300 }

          before do
            Application.save service_id: service_id, id: app_id, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'
          end

          it 'returns an empty list' do
            ApplicationKey.load_all(service_id, app_id).must_equal []
          end
        end
      end

      describe '.save' do
        let(:service_id) { 500 }
        let(:app_id)     { 500 }
        let(:key)      { "foobar" }

        before do
          ApplicationKey.delete(service_id, app_id, key)

          Application.save service_id: service_id, id: app_id, state: 'suspended',
                           plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'
        end

        it 'returns an ApplicationKey object' do
          application_key = ApplicationKey.save(service_id, app_id, key)

          application_key.must_be_kind_of ApplicationKey
          application_key.value.must_equal key
        end

        describe 'with a key that contains special chars (*, _, etc.)' do
          let(:key) { SPECIAL_CHARACTERS }

          before do
            ApplicationKey.delete(service_id, app_id, key)
          end

          it 'saves it correctly' do
            application_key = ApplicationKey.save(service_id, app_id, key)

            application_key.must_be_kind_of ApplicationKey
            application_key.value.must_equal key
          end
        end

        describe 'with app ID that contains special characters ({, $, ? etc.)' do
          let(:app_id) { SPECIAL_CHARACTERS }
          let(:key) { SPECIAL_CHARACTERS }

          before do
            ApplicationKey.delete(service_id, app_id, key)
          end

          it 'saves it correctly' do
            application_key = ApplicationKey.save(service_id, app_id, key)

            application_key.must_be_kind_of ApplicationKey
            application_key.value.must_equal key
          end
        end
      end

      describe '.delete' do
        let(:service_id) { 300 }
        let(:app_id) { 200 }
        let(:key) { 'foo' }

        before do
          Application.save service_id: service_id, id: app_id, state: 'suspended',
                           plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'
        end

        describe 'with an existing application key' do
          before do
            ApplicationKey.save(service_id, app_id, key)
          end

          it 'returns true' do
            ApplicationKey.delete(service_id, app_id, key).must_equal true
          end
        end

        describe 'with a non-existing application key' do
          let(:key) { 'non_existing_key' }

          it 'returns false' do
            ApplicationKey.delete(service_id, app_id, key).must_equal false
          end
        end

        describe 'with a key that contains special chars (*, _, etc.)' do
          let(:key_with_special_chars) { SPECIAL_CHARACTERS }

          before do
            ApplicationKey.save(service_id, app_id, key)
          end

          it 'returns true' do
            ApplicationKey.delete(service_id, app_id, key).must_equal true
          end
        end
      end
    end
  end
end
