require_relative './spec_helper'

module ThreeScale
  module Core
    describe Service do
      let(:default_service_id) { 7001 }
      let(:non_default_service_id) { default_service_id.succ }
      let(:non_existent_service_id) { non_default_service_id.succ }
      let(:default_provider_key) { 'foo' }
      let(:other_provider_key) { 'bazinga' }
      let(:another_provider_key) { 'bar' }
      let(:non_existent_provider_key) { 'bunga' }

      before do
        # We create a new service for our provider as the default, then
        # delete the service id we'll be using as the default service and
        # then create it -- this way we're sure we don't reuse anything from
        # previous runs.
        service = Service.save! provider_key: default_provider_key,
                                id: non_default_service_id,
                                default_service: true
        Service.load_by_id(service.id)
        Service.delete_by_id!(default_service_id) rescue nil

        service = Service.save! provider_key: default_provider_key,
                                id: default_service_id,
                                referrer_filters_required: true,
                                backend_version: 'oauth',
                                default_user_plan_id: 15,
                                default_user_plan_name: 'test name',
                                default_service: true
        raise unless service.default_service

        Service.delete_by_id!(non_default_service_id)
      end

      describe '.load_by_id' do
        describe 'with an existing service' do
          it 'returns a Service object' do
            Service.load_by_id(default_service_id).class.must_equal Service
          end

          it 'parses data from received JSON' do
            service = Service.load_by_id(default_service_id)

            service.wont_be_nil
            service.provider_key.must_equal default_provider_key
            service.id.must_equal default_service_id.to_s
            service.referrer_filters_required?.must_equal true
            service.user_registration_required?.must_equal true
            service.backend_version.must_equal 'oauth'
            service.default_user_plan_id.must_equal '15'
            service.default_user_plan_name.must_equal 'test name'
          end
        end

        describe 'with a missing service' do
          it 'returns nil' do
            Service.load_by_id(non_existent_service_id).must_be_nil
          end
        end
      end

      describe '.delete_by_id!' do
        before do
          Service.save! provider_key: default_provider_key,
                        id: default_service_id,
                        default_service: true
        end

        it 'returns true if deleting a non-default service' do
          Service.save! provider_key: default_provider_key,
                        id: non_default_service_id
          Service.delete_by_id!(non_default_service_id).must_equal true
        end

        it 'raises an exception when deleting a default service' do
          lambda do
            Service.delete_by_id! default_service_id
          end.must_raise ServiceIsDefaultService
        end
      end

      describe '.save!' do
        before do
          @service_params = {
            provider_key: default_provider_key,
            id: non_default_service_id
          }
        end

        it 'returns service object' do
          service = Service.save!(@service_params)

          service.wont_be_nil
          service.class.must_equal Service
          service.id.must_equal non_default_service_id
          service.provider_key.must_equal default_provider_key
        end

        it 'raises an exception when missing a default user plan' do
          @service_params.merge! user_registration_required: false

          lambda do
            Service.save!(@service_params)
          end.must_raise ServiceRequiresDefaultUserPlan
        end
      end

      describe '.make_default' do
        it 'returns the updated service' do
          service = Service.save!(id: non_default_service_id,
                                  provider_key: default_provider_key)
          Service.make_default(service.id).class.must_equal Service
        end
      end

      describe '.change_provider_key!' do
        def with_changed_provider_key(from, to)
          val = Service.change_provider_key!(from, to)
          yield val
          # change it back
          Service.change_provider_key!(to, from)
        end

        before do
          Service.save! provider_key: default_provider_key,
                        id: default_service_id
        end

        it 'returns true' do
          with_changed_provider_key default_provider_key, other_provider_key do |val|
            val.must_equal true
          end
        end

        it 'raises an exception when the key to change doesn\'t exist' do
          lambda do
            with_changed_provider_key(non_existent_provider_key, 'baz') { }
          end.must_raise ProviderKeyNotFound
        end

        it 'raises an exception when the new key already exists' do
          Service.save! provider_key: another_provider_key, id: non_default_service_id

          lambda do
            with_changed_provider_key(default_provider_key, another_provider_key) { }
          end.must_raise ProviderKeyExists
        end

        it 'raises an exception when the keys are invalid' do
          lambda do
            with_changed_provider_key(default_provider_key, '') { }
          end.must_raise InvalidProviderKeys
        end
      end
    end
  end
end
