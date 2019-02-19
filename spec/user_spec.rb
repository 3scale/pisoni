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
        Service.save! provider_key: provider_key,
                      id: service_id, default_service: true

        Service.delete_by_id! nonexistent_service_id rescue nil
        User.delete! service_id, nonexistent_username
        @user = User.save! service_id: service_id, username: username, state: state,
                           plan_id: plan_id, plan_name: plan_name
      end

      describe '.load' do
        it 'returns a User object' do
          User.load(service_id, username).class.must_equal User
        end

        it 'parses data from received JSON' do
          user = User.load(service_id, username)

          user.wont_be_nil
          user.service_id.must_equal service_id.to_s
          user.state.must_equal state.to_s
          user.plan_id.must_equal plan_id.to_s
          user.plan_name.must_equal plan_name
        end

        it 'raises when the service id is missing or empty' do
          ['', nil].each do |service_id|
            lambda do
              User.load service_id, username
            end.must_raise UserRequiresServiceId
          end
        end

        it 'raises when the user name is missing or empty' do
          ['', nil].each do |user_name|
            lambda do
              User.load service_id, user_name
            end.must_raise UserRequiresUsername
          end
        end

        it 'returns nil when a non-existent service id is used' do
          User.load(nonexistent_service_id, username).must_be_nil
        end

        it 'returns nil when a non-existent user name is used' do
           User.load(service_id, nonexistent_username).must_be_nil
        end
      end

      describe '.save!' do
        before do
          User.delete! service_id, nonexistent_username
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

        it 'raises when the service id is missing or empty' do
          ['', nil].each do |service_id|
            lambda do
              User.save! service_id: service_id, username: username, plan_id: plan_id,
                plan_name: plan_name
            end.must_raise UserRequiresServiceId
          end
        end

        it 'raises when the user name is missing or empty' do
          ['', nil].each do |user_name|
            lambda do
              User.save! service_id: service_id, username: user_name, plan_id: plan_id,
                plan_name: plan_name
            end.must_raise UserRequiresUsername
          end
        end

        it 'raises when a non-existent service id is used' do
          lambda do
            User.save! service_id: nonexistent_service_id, username: username,
                       plan_id: plan_id, plan_name: plan_name
          end.must_raise UserRequiresValidServiceId
        end

        it 'raises when plan_id is nil' do
          lambda do
            User.save! service_id: service_id, username: username,
                       plan_id: nil, plan_name: plan_name
          end.must_raise UserRequiresDefinedPlan
        end

        it 'raises when plan_name is nil' do
          lambda do
            User.save! service_id: service_id, username: username,
                       plan_id: plan_id, plan_name: nil
          end.must_raise UserRequiresDefinedPlan
        end

        it 'returns a new user when a non-existent user name is used' do
          nothing_raised do
            User.save! service_id: service_id, username: nonexistent_username,
                       plan_id: plan_id, plan_name: plan_name
          end.must_equal true

          user = User.load service_id, nonexistent_username

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
          User.save! service_id: service_id, username: username, state: state,
                     plan_id: plan_id, plan_name: plan_name
        end

        it 'deletes the user' do
          nothing_raised do
            User.delete! service_id, username
          end.must_equal true

          User.save! service_id: service_id, username: username, state: state,
                     plan_id: plan_id, plan_name: plan_name
        end
      end

      describe '.delete_all_for_service' do
        let(:service_id) { '2001_delete_all_for_service' }
        let(:provider_key) { 'provider_for_delete_all_for_service' }
        let(:state) { :active }

        before do
          Service.save! provider_key: provider_key, id: service_id, default_service: true
        end

        it 'deletes all users' do
          user01 = User.save!(service_id: service_id, username: 'username01', state: :active,
                              plan_id: 'plan_id_01', plan_name: 'plan_01')
          user02 = User.save!(service_id: service_id, username: 'username02', state: :active,
                              plan_id: 'plan_id_02', plan_name: 'plan_02')
          User.delete_all_for_service(service_id).must_equal true
          User.load(service_id, user01.username).must_be_nil
          User.load(service_id, user02.username).must_be_nil
        end

        it 'raises error on empty service' do
          proc { User.delete_all_for_service('') }.must_raise UserRequiresServiceId
        end

        it 'raises error on nil service' do
          proc { User.delete_all_for_service(nil) }.must_raise UserRequiresServiceId
        end
      end
    end
  end
end
