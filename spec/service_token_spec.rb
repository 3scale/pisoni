require_relative './spec_helper'

module ThreeScale
  module Core
    describe ServiceToken do

      let(:service_id) { '12345' }
      let(:token) { 'abcd' }
      let(:save_service_token_params) do
        {
          ab: { service_id: '1' },
          cd: { service_id: '2' },
          ef: { service_id: '3' }
        }
      end
      let(:delete_service_token_params) do
        save_service_token_params.map do |token, params|
          { service_id: params[:service_id], service_token: token }
        end
      end

      describe '.save' do

        describe 'when saving one token' do
          before do
            ServiceToken.delete([{ service_id: service_id, service_token: token }])
          end

          it 'saves a service token' do
            assert ServiceToken.save!(token => { service_id: service_id })

            result = ServiceToken.delete([{ service_id: service_id, service_token: token }])

            assert_equal result, 1
          end
        end

        describe 'when saving more tokens at once' do
          before do
            ServiceToken.delete(delete_service_token_params)
          end

          it 'saves service tokens' do
            assert ServiceToken.save!(save_service_token_params)

            result = ServiceToken.delete(delete_service_token_params)

            assert_equal result, save_service_token_params.size
          end
        end

        describe 'when the parameters are blank' do
          it 'does not save a service token' do
            assert_raises ServiceTokenMissingParameter do
               ServiceToken.save!({})
            end
          end
        end

        describe 'when the service ID is nil' do
          it 'does not save a service token' do
            assert_raises ServiceTokenRequiresServiceId do
              ServiceToken.save!(token => { service_id: nil })
            end
          end
        end

        describe 'when the service ID parameter does not exist' do
          it 'does not save a service token' do
            assert_raises ServiceTokenRequiresServiceId do
              ServiceToken.save!(token => { id: service_id })
            end
          end
        end

        describe 'when the token parameter does not exist' do
          it 'does not save a service token' do
            assert_raises ServiceTokenRequiresToken do
              ServiceToken.save!('' => { service_id: service_id })
            end
          end
        end
      end

      describe '.delete' do

        describe 'when deleting one token' do
          before do
            ServiceToken.save!(token => { service_id: service_id })
          end

          it 'deletes a service token' do
            result = ServiceToken.delete([{ service_id: service_id, service_token: token }])

            assert_equal result, 1
          end
        end

        describe 'when deleting more tokens at once' do
          before do
            ServiceToken.save!(save_service_token_params)
          end

          it 'deletes service tokens' do
            result = ServiceToken.delete(delete_service_token_params)

            assert_equal result, delete_service_token_params.size
          end
        end

        describe 'when deleting non existing token' do
          it 'returns zero count' do
            result = ServiceToken.delete([{ service_id: '1', service_token: 'a' }])

            assert_equal result, 0
          end
        end
      end
    end
  end
end
