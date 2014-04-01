require_relative './spec_helper'

module ThreeScale
  module Core
    describe Service do

      describe '.load_by_id' do
        describe 'with an existing service' do
          before do
            faraday_stub.get('/services/12') { [200, {},
              '{"backend_version":"oauth","default_user_plan_name":"test name",
              "version":"5","default_user_plan_id":"15","provider_key":"foo",
              "user_registration_required":true,"id":"12",
              "referrer_filters_required":true}'] }
          end

          it 'returns a Service object' do
            Service.load_by_id(12).class.must_equal Service
          end

          it 'parses data from received JSON' do
            service = Service.load_by_id(12)

            service.provider_key.must_equal 'foo'
            service.id.must_equal '12'
            service.referrer_filters_required?.must_equal true
            service.user_registration_required?.must_equal true
            service.backend_version.must_equal 'oauth'
            service.default_user_plan_id.must_equal '15'
            service.default_user_plan_name.must_equal 'test name'
          end
        end

        describe 'with a missing service' do
          it 'returns nil' do
            faraday_stub.get('/services/12') { [404, {},
              '{"error":"not_found"}'] }

            Service.load_by_id(12).must_equal nil
          end
        end
      end

      describe '.delete_by_id!' do
        it 'returns true if deleting a non-default service' do
          faraday_stub.delete('/services/12') { [200, {}, '{"status":"ok"}'] }

          Service.delete_by_id!(12).must_equal true
        end

        it 'raises an exception when deleting a default service' do
          faraday_stub.delete('/services/12') { [400, {}, '{"error":"blah"}'] }

          lambda { Service.delete_by_id! 12 }.must_raise ServiceIsDefaultService
        end

        it 'deletes the service if forced' do
          faraday_stub.delete('/services/12?force=true') { [200, {}, '{"status":"ok"}'] }

          Service.delete_by_id!(12, force: true).must_equal true
        end
      end

      describe '.save!' do
        before do
          @service_params = {provider_key: 'foo', id: '7001'}
        end

        it 'returns true' do
          faraday_stub.post('/services/', service: @service_params) { [201, {},
            '{"service":{"id":"7001","provider_key":"foo"},"status":"created"'] }

          Service.save!(@service_params).must_equal true
        end

        it 'raises an exception when missing a default user plan' do
          @service_params.merge! user_registration_required: false
          faraday_stub.post('/services/', service: @service_params) { [400, {},
            '{"error":"Services without the need for registered users require a default user plan"}'] }

          lambda { Service.save!(@service_params) }.must_raise ServiceRequiresDefaultUserPlan
        end
      end

      describe '.make_default' do
        before do
          @service = Service.new(id: 7001, provider_key: 'foo')
          faraday_stub.post('/services/',
            service: @service.attributes.merge(default_service: true)
          ) { [201, {},
            '{"service":{"id":"7001","provider_key":"foo"},"status":"created"'] }
        end

        it 'returns true' do
          @service.make_default.must_equal true
        end
      end

      describe '.change_provider_key!' do

        it 'returns true' do
          faraday_stub.put('services/change_provider_key/foo', new_key: 'bar'){
            [200, {}, '{"status":"ok"}'] }

          Service.change_provider_key!('foo', 'bar').must_equal true
        end

        it 'raises an exception when the key to change doesn\'t exist' do
          faraday_stub.put('services/change_provider_key/foo', new_key: 'bar'){
            [400, {}, '{"error":"Provider key=\"baz\" does not exist"}'] }

          lambda { Service.change_provider_key!('foo', 'bar') }.must_raise ProviderKeyNotFound
        end

        it 'raises an exception when the new key already exists' do
          faraday_stub.put('services/change_provider_key/foo', new_key: 'bar'){
            [400, {}, '{"error":"Provider key=\"bar\" already exists"}'] }

          lambda { Service.change_provider_key!('foo', 'bar') }.must_raise ProviderKeyExists
        end

        it 'raises an exception when the keys are invalid' do
          faraday_stub.put('services/change_provider_key/foo', new_key: 'bar'){
            [400, {}, '{"error":"Provider keys are not valid, must be not nil and different"}'] }

          lambda { Service.change_provider_key!('foo', 'bar') }.must_raise InvalidProviderKeys
        end
      end

    end
  end
end
