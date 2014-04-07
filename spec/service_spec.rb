require_relative './spec_helper'

module ThreeScale
  module Core
    describe Service do

      describe '.load_by_id' do
        describe 'with an existing service' do
          before do
            VCR.use_cassette 'save default service for load' do
              Service.save! provider_key: 'foo', id: 7001,
                referrer_filters_required: true, backend_version: 'oauth',
                default_user_plan_id: 15, default_user_plan_name: 'test name'
            end
          end

          it 'returns a Service object' do
            VCR.use_cassette 'service load' do
              Service.load_by_id(7001).class.must_equal Service
            end
          end

          it 'parses data from received JSON' do
            service = VCR.use_cassette 'service load' do
              Service.load_by_id(7001)
            end

            service.provider_key.must_equal 'foo'
            service.id.must_equal '7001'
            service.referrer_filters_required?.must_equal true
            service.user_registration_required?.must_equal true
            service.backend_version.must_equal 'oauth'
            service.default_user_plan_id.must_equal '15'
            service.default_user_plan_name.must_equal 'test name'
          end
        end

        describe 'with a missing service' do
          it 'returns nil' do
            VCR.use_cassette 'service load empty' do
              Service.load_by_id(7002).must_equal nil
            end
          end
        end
      end

      describe '.delete_by_id!' do
        before do
          VCR.use_cassette 'save default service for delete' do
            Service.save! provider_key: 'foo', id: 7001
          end
        end

        it 'returns true if deleting a non-default service' do
          VCR.use_cassette 'save additional service' do
            Service.save! provider_key: 'foo', id: 7002
          end

          VCR.use_cassette 'delete non-default service' do
            Service.delete_by_id!(7002).must_equal true
          end
        end

        it 'raises an exception when deleting a default service' do
          lambda do
            VCR.use_cassette 'delete default service' do
              Service.delete_by_id! 7001
            end
          end.must_raise ServiceIsDefaultService
        end

        it 'deletes the service if forced' do
          VCR.use_cassette 'force delete default service' do
            Service.delete_by_id!(7001, force: true).must_equal true
          end
        end
      end

      describe '.save!' do
        before { @service_params = {provider_key: 'foo', id: '7001'} }

        it 'returns service object' do
          service = VCR.use_cassette 'save with default service params' do
            Service.save!(@service_params)
          end

          service.class.must_equal Service
          service.id.must_equal '7001'
          service.provider_key.must_equal 'foo'
        end

        it 'raises an exception when missing a default user plan' do
          @service_params.merge! user_registration_required: false

          lambda do
            VCR.use_cassette 'save without registration required' do
              Service.save!(@service_params)
            end
          end.must_raise ServiceRequiresDefaultUserPlan
        end
      end

      describe '.make_default' do
        it 'returns the updated service' do
          service = VCR.use_cassette 'save a default service for make_default' do
            Service.save!(id: 7001, provider_key: 'foo')
          end

          VCR.use_cassette 'make a service default' do
            service.make_default.class.must_equal Service
          end
        end
      end

      describe '.change_provider_key!' do
        before do
          VCR.use_cassette 'save default service for changing provider key' do
            Service.save! provider_key: 'foo', id: 7001
          end
        end

        it 'returns true' do
          VCR.use_cassette 'changing a provider key' do
            Service.change_provider_key!('foo', 'bazinga').must_equal true
          end
        end

        it 'raises an exception when the key to change doesn\'t exist' do
          lambda do
            VCR.use_cassette 'changing a non-exisiting provider key' do
              Service.change_provider_key!('bunga', 'baz')
            end
          end.must_raise ProviderKeyNotFound
        end

        it 'raises an exception when the new key already exists' do
          VCR.use_cassette 'additional service for changing a provider key' do
            Service.save! provider_key: 'bar', id: 7002
          end

          lambda do
            VCR.use_cassette 'changing a provider key to existing one' do
              Service.change_provider_key!('foo', 'bar')
            end
          end.must_raise ProviderKeyExists
        end

        it 'raises an exception when the keys are invalid' do
          lambda do
            VCR.use_cassette 'changing a provider key to invalid one' do
              Service.change_provider_key!('foo', '')
            end
          end.must_raise InvalidProviderKeys
        end
      end

    end
  end
end
