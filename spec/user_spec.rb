require_relative './spec_helper'

module ThreeScale
  module Core
    describe User do
      def nothing_raised
        yield
        true
      rescue => e
        e
      end

      let(:service_id) { 2001 }
      let(:nonexistent_service_id) { service_id.succ }
      let(:provider_key) { 'provider_for_user_spec' }
      let(:username) { 'pancho' }
      let(:nonexistent_username) { 'rodolfo' }
      let(:state) { :active }
      let(:plan_id) { 6789 }
      let(:plan_name) { 'plan_for_panchos' }

      before do
        VCR.use_cassette 'ensure we have a service available' do
          Service.save! provider_key: provider_key,
            id: service_id, default_service: true
        end
        VCR.use_cassette 'ensure we have a non-existent service id' do
          Service.delete_by_id! nonexistent_service_id rescue nil
        end
        VCR.use_cassette 'ensure we have a non-existent username' do
          User.delete! service_id, nonexistent_username
        end
        @user = VCR.use_cassette 'save sample user' do
          User.save! service_id: service_id, username: username, state: state,
            plan_id: plan_id, plan_name: plan_name
        end
      end

      describe '.load' do
        it 'returns a User object' do
          VCR.use_cassette 'user load' do
            User.load(service_id, username)
          end.class.must_equal User
        end

        it 'parses data from received JSON' do
          user = VCR.use_cassette 'user load' do
            User.load(service_id, username)
          end

          user.wont_be_nil
          user.service_id.must_equal service_id.to_s
          user.state.must_equal state.to_s
          user.plan_id.must_equal plan_id.to_s
          user.plan_name.must_equal plan_name
        end

        it 'raises when the service id is missing' do
          lambda do
            User.load nil, username
          end.must_raise UserRequiresServiceId
        end

        it 'raises when the user name is missing' do
          lambda do
            User.load service_id, nil
          end.must_raise UserRequiresUsername
        end

        it 'returns nil when a non-existent service id is used' do
          VCR.use_cassette 'load with non-existent service id' do
            User.load nonexistent_service_id, username
          end.must_be_nil
        end

        it 'returns nil when a non-existent user name is used' do
          VCR.use_cassette 'load with non-existent user name' do
            User.load service_id, nonexistent_username
          end.must_be_nil
        end
      end

      describe '.save!' do
        before do
          VCR.use_cassette 'ensure we have a non-existent username' do
            User.delete! service_id, nonexistent_username
          end
        end

        it 'returns a User object' do
          @user.wont_be_nil
          @user.class.must_equal User
        end

        it 'returns an object with the saved attributes' do
          @user.wont_be_nil
          @user.service_id.must_equal service_id.to_s
          @user.username.must_equal username
          @user.state.must_equal state.to_s
          @user.plan_id.must_equal plan_id
          @user.plan_name.must_equal plan_name
        end

        it 'raises when the service id is missing' do
          lambda do
            User.save! service_id: nil, username: username, plan_id: plan_id,
              plan_name: plan_name
          end.must_raise UserRequiresServiceId
        end

        it 'raises when the user name is missing' do
          lambda do
            User.save! service_id: service_id, username: nil, plan_id: plan_id,
              plan_name: plan_name
          end.must_raise UserRequiresUsername
        end

        it 'raises when a non-existent service id is used' do
          lambda do
            VCR.use_cassette 'save with non-existent service id' do
              User.save! service_id: nonexistent_service_id, username: username,
                plan_id: plan_id, plan_name: plan_name
            end
          end.must_raise UserRequiresValidServiceId
        end

        it 'raises when plan_id is nil' do
          lambda do
            VCR.use_cassette 'save with non-existent service id' do
              User.save! service_id: service_id, username: username,
                plan_id: nil, plan_name: plan_name
            end
          end.must_raise UserRequiresDefinedPlan
        end

        it 'raises when plan_name is nil' do
          lambda do
            VCR.use_cassette 'save with non-existent service id' do
              User.save! service_id: service_id, username: username,
                plan_id: plan_id, plan_name: nil
            end
          end.must_raise UserRequiresDefinedPlan
        end

        it 'returns a new user when a non-existent user name is used' do
          nothing_raised do
            VCR.use_cassette 'save with a non-existent user name' do
              User.save! service_id: service_id, username: nonexistent_username,
                plan_id: plan_id, plan_name: plan_name
            end
          end.must_equal true

          user = VCR.use_cassette 'load a previously non-existent user name' do
            User.load service_id, nonexistent_username
          end

          user.wont_be_nil
          user.service_id.must_equal service_id.to_s
          user.username.must_equal nonexistent_username
          user.state.must_equal state.to_s
          user.plan_id.must_equal plan_id.to_s
          user.plan_name.must_equal plan_name
        end
      end

      describe '.delete!' do
        before do
          VCR.use_cassette 'save sample user' do
            User.save! service_id: service_id, username: username, state: state,
              plan_id: plan_id, plan_name: plan_name
          end
        end

        it 'deletes the user' do
          nothing_raised do
            VCR.use_cassette 'delete sample user' do
              User.delete! service_id, username
            end
          end.must_equal true

          VCR.use_cassette 'save sample user' do
            User.save! service_id: service_id, username: username, state: state,
              plan_id: plan_id, plan_name: plan_name
          end
        end
      end

    end
  end
end
