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

    end
  end
end
