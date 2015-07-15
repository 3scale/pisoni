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
        VCR.use_cassette 'ensures our default service id is free' do
          service = Service.save! provider_key: default_provider_key,
            id: non_default_service_id,
            default_service: true
          Service.load_by_id(service.id)
          Service.delete_by_id!(default_service_id) rescue nil
        end
        VCR.use_cassette 'save default service for load_by_id' do
          service = Service.save! provider_key: default_provider_key,
            id: default_service_id,
            referrer_filters_required: true,
            backend_version: 'oauth',
            default_user_plan_id: 15,
            default_user_plan_name: 'test name',
            default_service: true
          raise unless service.default_service
        end
        VCR.use_cassette 'remove temporary default service id' do
          Service.delete_by_id!(non_default_service_id)
        end
      end

      describe '.load_by_id' do
        describe 'with an existing service' do
          it 'returns a Service object' do
            VCR.use_cassette 'service load' do
              Service.load_by_id(default_service_id)
            end.class.must_equal Service
          end

          it 'parses data from received JSON' do
            service = VCR.use_cassette 'service load' do
              Service.load_by_id(default_service_id)
            end

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
            VCR.use_cassette 'service load empty' do
              Service.load_by_id(non_existent_service_id)
            end.must_be_nil
          end
        end
      end

      describe '.delete_by_id!' do
        before do
          VCR.use_cassette 'save default service for delete' do
            Service.save! provider_key: default_provider_key,
                          id: default_service_id,
                          default_service: true
          end
        end

        it 'returns true if deleting a non-default service' do
          VCR.use_cassette 'deleting non-default service' do
            Service.save! provider_key: default_provider_key,
                          id: non_default_service_id
            Service.delete_by_id!(non_default_service_id)
          end.must_equal true
        end

        it 'raises an exception when deleting a default service' do
          lambda do
            VCR.use_cassette 'delete default service' do
              Service.delete_by_id! default_service_id
            end
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
          service = VCR.use_cassette 'save with default service params' do
            Service.save!(@service_params)
          end

          service.wont_be_nil
          service.class.must_equal Service
          service.id.must_equal non_default_service_id
          service.provider_key.must_equal default_provider_key
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
          VCR.use_cassette 'make a service default' do
            service = Service.save!(id: non_default_service_id,
                                    provider_key: default_provider_key)
            Service.make_default(service.id)
          end.class.must_equal Service
        end
      end

      describe '.change_provider_key!' do
        def with_changed_provider_key(from, to)
          val = VCR.use_cassette "changing provider key from #{from} to #{to}" do
            Service.change_provider_key!(from, to)
          end
          yield val
          # change it back
          VCR.use_cassette "changing back provider key from #{to} to #{from}" do
            Service.change_provider_key!(to, from)
          end
        end

        before do
          VCR.use_cassette 'save default service for changing provider key' do
            Service.save! provider_key: default_provider_key,
                          id: default_service_id
          end
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
          VCR.use_cassette 'additional service for changing a provider key' do
            Service.save! provider_key: another_provider_key, id: non_default_service_id
          end

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

      describe '.set_log_bucket' do
        let(:bucket){ 'foobar' }

        it 'returns true' do
          VCR.use_cassette "setting log bucket as #{bucket}" do
            Service.set_log_bucket(default_service_id, bucket).must_equal true
          end
        end

        it 'raises exception when no bucket specified' do
          VCR.use_cassette "setting log bucket as ''" do
            lambda do
              Service.set_log_bucket(default_service_id, '').must_equal false
            end.must_raise InvalidBucket
          end
        end
      end

    end
  end
end
