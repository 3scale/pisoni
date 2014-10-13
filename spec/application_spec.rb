require_relative './spec_helper'

module ThreeScale
  module Core
    describe Application do
      describe '.load' do
        describe 'with an existing application' do
          before do
            VCR.use_cassette 'delete sample application' do
              Application.delete(2001, 8011)
            end
            VCR.use_cassette 'save sample application' do
              # note that version: 666 should not be saved!
              Application.save service_id: 2001, id: 8011, state: 'suspended',
                plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                version: '666'
            end
          end

          it 'returns an Application object' do
            VCR.use_cassette 'load sample application' do
              Application.load(2001, 8011)
            end.class.must_equal Application
          end

          it 'parses data from received JSON' do
            application = VCR.use_cassette 'load sample application' do
              Application.load(2001, 8011)
            end

            application.service_id.must_equal '2001'
            application.id.must_equal '8011'
            application.state.must_equal 'suspended'
            application.plan_id.must_equal '3066'
            application.plan_name.must_equal 'crappy'
            application.redirect_url.must_equal 'blah'
            application.version.must_equal 1
          end
        end

        describe 'with a missing application' do
          it 'returns nil' do
            VCR.use_cassette 'load application id missing' do
              Application.load(2001, 7999)
            end.must_be_nil
          end
        end

        describe 'with a missing service' do
          it 'returns nil' do
            VCR.use_cassette 'load application service id missing' do
              Application.load(1999, 8011)
            end.must_be_nil
          end
        end

        describe 'with both application and service missing' do
          it 'returns nil' do
            VCR.use_cassette 'load service and application ids missing' do
              Application.load(1999, 7999)
            end.must_be_nil
          end
        end
      end

      describe '.delete' do
        before do
          VCR.use_cassette 'delete sample application' do
            Application.delete(2001, 8011)
          end
          VCR.use_cassette 'save sample application' do
            # note that version: 666 should not be saved!
            Application.save service_id: 2001, id: 8011, state: 'suspended',
              plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
              version: '666'
          end
        end

        describe 'with an existing application' do
          it 'returns true when deleting an existing application' do
            VCR.use_cassette 'delete sample application' do
              Application.delete(2001, 8011)
            end.must_equal true
          end

          it 'makes it non-existent' do
            VCR.use_cassette 'delete sample application' do
              Application.delete(2001, 8011)
            end
            VCR.use_cassette 'load inexistent sample application' do
              Application.load(2001, 8011)
            end.must_equal nil
          end
        end

        describe 'with a non-existing application' do
          it 'returns false when deleting an application with missing id' do
            VCR.use_cassette 'delete a missing id application' do
              Application.delete(2001, 7999)
            end.must_equal false
          end

          it 'returns false when deleting an application with missing service id' do
            VCR.use_cassette 'delete a missing service id application' do
              Application.delete(1999, 8011)
            end.must_equal false
          end
        end
      end

      describe '.save' do
        before do
          VCR.use_cassette 'delete sample application' do
            Application.delete(2001, 8011)
          end
          @app = VCR.use_cassette 'save sample application' do
            # note that version: 666 should not be saved!
            Application.save service_id: 2001, id: 8011, state: 'suspended',
              plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
              version: '666'
          end
        end

        it 'exists' do
          VCR.use_cassette '.save load application instance' do
            Application.load(@app.service_id, @app.id)
          end.wont_be_nil
        end

        it 'returns an Application object' do
          @app.must_be_kind_of Application
        end

        it 'returns an Application object with correct fields' do
          @app.id.must_equal '8011'
          @app.service_id.must_equal '2001'
          @app.state.must_equal 'suspended'
          @app.plan_id.must_equal '3066'
          @app.plan_name.must_equal 'crappy'
          @app.redirect_url.must_equal 'blah'
          @app.version.must_equal 1
        end

        it 'modifies the application when saving an existing one' do
          new_app = VCR.use_cassette 'save with an existing application' do
            Application.save service_id: @app.service_id, id: @app.id, state: @app.state,
              plan_id: @app.plan_id, plan_name: @app.plan_name, redirect_url: 'someurl',
              version: '665'
          end
          new_app.id.must_equal(@app.id)
          new_app.service_id.must_equal(@app.service_id)
          new_app.state.must_equal(@app.state)
          new_app.plan_id.must_equal(@app.plan_id)
          new_app.plan_name.must_equal(@app.plan_name)
          new_app.redirect_url.must_equal 'someurl'
          new_app.version.must_equal(@app.version + 1)

          reloaded_app = VCR.use_cassette 'reload sample application after changes' do
            Application.load(@app.service_id, @app.id)
          end
          new_app.redirect_url.must_equal(reloaded_app.redirect_url)
          new_app.version.must_equal(reloaded_app.version)
        end
      end

      describe '#save' do
        before do
          VCR.use_cassette 'delete sample application' do
            Application.delete(2001, 8011)
          end
          @app = VCR.use_cassette 'save sample application' do
            # note that version: 666 should not be saved!
            Application.save service_id: 2001, id: 8011, state: 'suspended',
              plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
              version: '666'
          end
        end

        it 'exists' do
          VCR.use_cassette '#save load application instance' do
            Application.load(@app.service_id, @app.id)
          end.wont_be_nil
        end

        it 'saves changes to an instance' do
          @app.plan_name = 'some_other_plan'
          VCR.use_cassette 'save instance app with different plan name' do
            @app.save
          end
          newapp = VCR.use_cassette 'load from saved instance app identifier' do
            Application.load @app.service_id, @app.id
          end
          newapp.id.must_equal @app.id
          newapp.service_id.must_equal @app.service_id
          newapp.state.must_equal @app.state
          newapp.plan_id.must_equal @app.plan_id
          newapp.redirect_url.must_equal @app.redirect_url
          newapp.plan_name.must_equal 'some_other_plan'
          newapp.version.must_equal @app.version
        end

        it 'increases the version' do
          old_version = @app.version
          VCR.use_cassette 'save instance app with different plan name' do
            @app.save
          end
          @app.version.must_equal(old_version + 1)
          newapp = VCR.use_cassette 'load from saved instance app identifier' do
            Application.load @app.service_id, @app.id
          end
          newapp.version.must_equal @app.version
        end
      end

      describe 'by_key' do
        before do
          VCR.use_cassette 'save an app ID by key' do
            Application.save_id_by_key(2001, 'a_key', 8011)
          end
        end

        describe '.load_id_by_key' do
          it 'returns the app ID linked to the specified service and key' do
            VCR.use_cassette 'load id by key' do
              Application.load_id_by_key(2001, 'a_key')
            end.must_equal '8011'
          end
        end

        describe '.save_id_by_key' do
          it 'changes the key linked to the app ID and service' do
            VCR.use_cassette 'get modified user key app ID' do
              Application.load_id_by_key(2001, 'another_key')
            end.must_be_nil
            VCR.use_cassette 'change key of service and app' do
              Application.save_id_by_key(2001, 'another_key', 8011)
            end.must_equal true
            VCR.use_cassette 'get modified user key app ID' do
              Application.load_id_by_key(2001, 'another_key')
            end.must_equal '8011'
          end
        end

        describe '.delete_id_by_key' do
          it 'deletes the key linked to the app ID and service' do
            VCR.use_cassette 'load app id using a not yet deleted key' do
              Application.load_id_by_key(2001, 'a_key')
            end.must_equal '8011'
            VCR.use_cassette 'delete the key linking app ID and service' do
              Application.delete_id_by_key(2001, 'a_key')
            end
            VCR.use_cassette 'load app id using a deleted key' do
              Application.load_id_by_key(2001, 'a_key')
            end.must_be_nil
          end
        end
      end

    end
  end
end
