require_relative './spec_helper'

module ThreeScale
  module Core
    describe Service do

      describe '.list' do
        before do
          faraday_stub.get('/services/?provider_key=foo') { [200, {}, '["7001","7002"]'] }
        end

        it 'returns an array of integer strings' do
          Service.list('foo').must_equal ['7001', '7002']
        end
      end

      describe '.load_by_id' do
        before do
          faraday_stub.get('/services/12') { [200, {},
            '{"backend_version":"oauth","default_user_plan_name":"test name",
            "version":"5","default_user_plan_id":"15","provider_key":"foo",
            "user_registration_required":true,"id":"12",
            "referrer_filters_required":true,"default_service":true}'] }
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
          service.default_service?.must_equal true
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

    end
  end
end
