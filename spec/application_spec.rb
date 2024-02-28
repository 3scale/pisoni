require_relative './spec_helper'

module ThreeScale
  module Core
    describe Application do
      describe '.load' do
        describe 'with an existing application' do
          before do
            Application.delete(2001, 8011)
            Application.save service_id: 2001, id: 8011, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'
          end

          it 'returns an Application object' do
            Application.load(2001, 8011).class.must_equal Application
          end

          it 'parses data from received JSON' do
            application = Application.load(2001, 8011)

            application.service_id.must_equal '2001'
            application.id.must_equal '8011'
            application.active?.must_equal false
            application.plan_id.must_equal '3066'
            application.plan_name.must_equal 'crappy'
            application.redirect_url.must_equal 'blah'
          end
        end

        describe 'with a missing application' do
          it 'returns nil' do
            Application.load(2001, 7999).must_be_nil
          end
        end

        describe 'with a missing service' do
          it 'returns nil' do
            Application.load(1999, 8011).must_be_nil
          end
        end

        describe 'with both application and service missing' do
          it 'returns nil' do
            Application.load(1999, 7999).must_be_nil
          end
        end

        describe 'with an app ID that contains special characters' do
          let(:service_id) { 2001 }
          let(:app_id) { SPECIAL_CHARACTERS }

          before do
            Application.save service_id: service_id, id: app_id, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'
          end

          it 'returns an app with the correct ID' do
            Application.load(service_id, app_id).id.must_equal app_id
          end
        end
      end

      describe '.delete' do
        before do
          Application.delete(2001, 8011)
          Application.save service_id: 2001, id: 8011, state: 'suspended',
                           plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'
        end

        describe 'with an existing application' do
          it 'returns true when deleting an existing application' do
            Application.delete(2001, 8011).must_equal true
          end

          it 'makes it non-existent' do
            Application.delete(2001, 8011)
            Application.load(2001, 8011).must_equal nil
          end
        end

        describe 'with a non-existing application' do
          it 'returns false when deleting an application with missing id' do
            Application.delete(2001, 7999).must_equal false
          end

          it 'returns false when deleting an application with missing service id' do
            Application.delete(1999, 8011).must_equal false
          end
        end

        describe 'with an app ID that contains special characters' do
          let(:service_id) { 2001 }
          let(:app_id) { SPECIAL_CHARACTERS }

          before do
            Application.save service_id: service_id, id: app_id, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'
          end

          it 'returns true when deleting an existing app' do
            Application.delete(service_id, app_id).must_equal true
          end
        end
      end

      describe '.save' do
        before do
          Application.delete(2001, 8011)
          @app = Application.save service_id: 2001, id: 8011, state: 'suspended',
                                  plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'
        end

        it 'exists' do
          Application.load(@app.service_id, @app.id).wont_be_nil
        end

        it 'returns an Application object' do
          @app.must_be_kind_of Application
        end

        it 'returns an Application object with correct fields' do
          @app.id.must_equal '8011'
          @app.service_id.must_equal '2001'
          @app.active?.must_equal false
          @app.plan_id.must_equal '3066'
          @app.plan_name.must_equal 'crappy'
          @app.redirect_url.must_equal 'blah'
        end

        it 'modifies the application when saving an existing one' do
          new_app = Application.save service_id: @app.service_id, id: @app.id, state: @app.state,
                                     plan_id: @app.plan_id, plan_name: @app.plan_name, redirect_url: 'someurl'

          new_app.id.must_equal(@app.id)
          new_app.service_id.must_equal(@app.service_id)
          new_app.state.must_equal(@app.state)
          new_app.plan_id.must_equal(@app.plan_id)
          new_app.plan_name.must_equal(@app.plan_name)
          new_app.redirect_url.must_equal 'someurl'

          reloaded_app = Application.load(@app.service_id, @app.id)

          new_app.redirect_url.must_equal(reloaded_app.redirect_url)
        end

        it 'raises a client-side error when missing mandatory attributes' do
          {service_id: 9000, foo: 'bar', bar: 'foo', id: 6077}.each_cons(2) do |attrs|
            attrs = attrs.to_h
            # note missing service_id, id
            attrs.merge!(state: 'suspended', plan_id: '3066',
              plan_name: 'crappy', redirect_url: 'blah')
            lambda do
              Application.save(attrs)
            end.must_raise KeyError # minitest wont catch parent exceptions :/
          end
        end

        describe 'with an app ID that contains special characters' do
          let(:service_id) { 2001 }
          let(:app_id) { SPECIAL_CHARACTERS }

          before do
            Application.delete(service_id, app_id)
          end

          it 'returns an object with the correct ID' do
            app = Application.save service_id: service_id, id: app_id, state: 'suspended',
                                   plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'

            app.id.must_equal app_id
          end
        end
      end

      describe '#save' do
        before do
          Application.delete(2001, 8011)
          @app = Application.save service_id: 2001, id: 8011, state: 'suspended',
                                  plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah'
        end

        it 'exists' do
          Application.load(@app.service_id, @app.id).wont_be_nil
        end

        it 'saves changes to an instance' do
          @app.plan_name = 'some_other_plan'
          @app.save
          newapp = Application.load @app.service_id, @app.id

          newapp.id.must_equal @app.id
          newapp.service_id.must_equal @app.service_id
          newapp.state.must_equal @app.state
          newapp.plan_id.must_equal @app.plan_id
          newapp.redirect_url.must_equal @app.redirect_url
          newapp.plan_name.must_equal 'some_other_plan'
        end

        it 'save active application' do
          @app.activate
          @app.save
          newapp = Application.load @app.service_id, @app.id
          newapp.active?.must_equal true
        end

        it 'save inactive application' do
          @app.deactivate
          @app.save
          newapp = Application.load @app.service_id, @app.id
          newapp.active?.must_equal false
        end

        it 'save application with no explicit state' do
          svc_id = 2001
          app_id = 9011
          # Make sure there is nothing in db
          Application.delete(svc_id, app_id)
          Application.load(svc_id, app_id).must_be_nil
          app_def_state = Application.new service_id: svc_id, id: app_id
          app_def_state.save
          newapp = Application.load app_def_state.service_id, app_def_state.id
          newapp.wont_be_nil
          newapp.active?.must_equal true
        end
      end

      describe '.active?' do
        it 'should be active when application is initialized as active' do
          [
            { state: :active },
            { state: 'active' },
            # even when state is not set
            {},
            # even when state is intentionally set as nil
            { state: nil }
          ].each do |app_attrs|
            Application.new(app_attrs).active?.must_equal true
          end
        end

        it 'should be inactive when application is initialized as disabled' do
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
          ].each do |app_attrs|
            Application.new(app_attrs).active?.must_equal false
          end
        end

        it 'should be active when the application is activated' do
          app = Application.new(state: :disable)
          app.active?.must_equal false
          app.activate
          app.active?.must_equal true
        end

        it 'should be inactive when the application is deactivated' do
          app = Application.new(state: :active)
          app.active?.must_equal true
          app.deactivate
          app.active?.must_equal false
        end
      end

      describe 'by_key' do
        let(:key) { 'a_key' }
        let(:key_with_special_chars) { SPECIAL_CHARACTERS }
        let(:service_id) { 2001 }
        let(:app_id) { 8011 }

        before do
          Application.save_id_by_key(service_id, key, app_id)
        end

        describe '.load_id_by_key' do
          it 'returns the app ID linked to the specified service and key' do
            Application.load_id_by_key(service_id, key).must_equal app_id.to_s
          end

          describe 'with a key that contains special chars (*, _, etc.)' do
            before do
              Application.save_id_by_key(service_id, key_with_special_chars, app_id)
            end

            it 'returns the correct app ID' do
              Application.load_id_by_key(service_id, key_with_special_chars).must_equal app_id.to_s
            end
          end
        end

        describe '.save_id_by_key' do
          let(:another_key) { key.succ }

          it 'changes the key linked to the app ID and service' do
            Application.load_id_by_key(service_id, another_key).must_be_nil
            Application.save_id_by_key(service_id, another_key, app_id).must_equal true
            Application.load_id_by_key(service_id, another_key).must_equal app_id.to_s
            # clean up this key
            Application.delete_id_by_key(service_id, another_key)
          end

          describe 'with a key that contains special chars (*, _, etc.)' do
            after do
              Application.delete_id_by_key(service_id, key_with_special_chars)
            end

            it 'changes the key linked to the app ID and service' do
              Application.save_id_by_key(service_id, key_with_special_chars, app_id).must_equal true
              Application.load_id_by_key(service_id, key_with_special_chars).must_equal app_id.to_s
            end
          end
        end

        describe '.delete_id_by_key' do
          it 'deletes the key linked to the app ID and service' do
            Application.load_id_by_key(service_id, key).must_equal app_id.to_s
            Application.delete_id_by_key(service_id, key)
            Application.load_id_by_key(service_id, key).must_be_nil
          end

          describe 'with a key that contains special chars (*, _, etc.)' do
            before do
              Application.save_id_by_key(service_id, key_with_special_chars, app_id)
            end

            it 'deletes the app' do
              Application.delete_id_by_key(service_id, key_with_special_chars)
              Application.load_id_by_key(service_id, key_with_special_chars).must_be_nil
            end
          end
        end
      end
    end
  end
end
