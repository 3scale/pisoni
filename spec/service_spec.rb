require_relative './spec_helper'

module ThreeScale
  module Core
    describe Service do
      let(:default_service_id) { 7001 }
      let(:non_default_service_id) { default_service_id.succ }
      let(:non_existent_service_id) { non_default_service_id.succ }
      let(:default_provider_key) { 'foo_service_spec' }
      let(:other_provider_key) { 'bazinga_service_spec' }
      let(:another_provider_key) { 'bar_service_spec' }
      let(:non_existent_provider_key) { 'bunga_service_spec' }

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
        it 'returns true if deleting a non-default service' do
          Service.save! provider_key: default_provider_key,
                        id: non_default_service_id
          Service.delete_by_id!(non_default_service_id).must_equal true
        end

        it 'raises an exception when deleting a default service and not unique' do
          Service.save! provider_key: default_provider_key, id: non_default_service_id
          lambda do
            Service.delete_by_id! default_service_id
          end.must_raise ServiceIsDefaultService
        end

        it 'returns true when deleting a default service and is unique for the provider' do
          Service.delete_by_id!(default_service_id).must_equal true
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

        it 'save active service' do
          service = Service.new(@service_params)
          service.wont_be_nil
          service.activate
          service.active?.must_equal true
          service.save!
          loaded_service = Service.load_by_id(@service_params[:id])
          loaded_service.wont_be_nil
          loaded_service.active?.must_equal true
        end

        it 'save disable service' do
          service = Service.new(@service_params)
          service.wont_be_nil
          service.deactivate
          service.active?.must_equal false
          service.save!
          loaded_service = Service.load_by_id(@service_params[:id])
          loaded_service.wont_be_nil
          loaded_service.active?.must_equal false
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

      describe '.active?' do
        it 'should be active when service is initialized as active' do
          [
            { state: :active },
            { state: 'active' },
            # even when state is not set
            {},
            # even when state is intentionally set as nil
            { state: nil }
          ].each do |svc_attrs|
            Service.new(svc_attrs).active?.must_equal true
          end
        end

        it 'should be inactive when service is initialized as disabled' do
          [
            { state: :suspended },
            { state: 'suspended' },
            { state: :something },
            { state: :disable },
            { state: :disabled },
            { state: '1' },
            { state: '0' },
            { state: 'true' },
            { state: 'false' }
          ].each do |svc_attrs|
            Service.new(svc_attrs).active?.must_equal false
          end
        end

        it 'should be active when the service is activated' do
          s = Service.new(state: :disable)
          s.active?.must_equal false
          s.activate
          s.active?.must_equal true
        end

        it 'should be disabled when the service is deactivated' do
          s = Service.new(state: :active)
          s.active?.must_equal true
          s.deactivate
          s.active?.must_equal false
        end
      end

      describe '.delete_stats' do
        let(:service_id) { default_service_id }
        let(:applications) { %w[1 2 3] }
        let(:metrics) { %w[10 20 30] }
        let(:users) { %w[100 200 300] }
        let(:from) { Time.new(2002, 10, 31).to_i }
        let(:to) { Time.new(2003, 10, 31).to_i }
        let(:delete_job) do
          {
            deletejobdef: {
              applications: applications,
              metrics: metrics,
              users: users,
              from: from,
              to: to
            }
          }
        end

        describe 'with valid job' do
          it 'does not raise error' do
            Service.delete_stats(default_service_id, delete_job).must_equal true
          end
        end
      end
    end
  end
end
