require_relative './spec_helper'

module ThreeScale
  module Core
    describe Application do
      describe '.load' do
        describe 'with an existing application' do
          before do
            Application.delete(2001, 8011)
            # note that version: 666 should not be saved!
            Application.save service_id: 2001, id: 8011, state: 'suspended',
                             plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                             version: '666'
          end

          it 'returns an Application object' do
            Application.load(2001, 8011).class.must_equal Application
          end

          it 'parses data from received JSON' do
            application = Application.load(2001, 8011)

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
      end

      describe '.delete' do
        before do
          Application.delete(2001, 8011)
          # note that version: 666 should not be saved!
          Application.save service_id: 2001, id: 8011, state: 'suspended',
                           plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                           version: '666'
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
      end

      describe '.save' do
        before do
          Application.delete(2001, 8011)
          # note that version: 666 should not be saved!
          @app = Application.save service_id: 2001, id: 8011, state: 'suspended',
                                  plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                                  version: '666'
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
          @app.state.must_equal 'suspended'
          @app.plan_id.must_equal '3066'
          @app.plan_name.must_equal 'crappy'
          @app.redirect_url.must_equal 'blah'
          @app.version.must_equal 1
        end

        it 'modifies the application when saving an existing one' do
          new_app = Application.save service_id: @app.service_id, id: @app.id, state: @app.state,
                                     plan_id: @app.plan_id, plan_name: @app.plan_name, redirect_url: 'someurl',
                                     version: '665'

          new_app.id.must_equal(@app.id)
          new_app.service_id.must_equal(@app.service_id)
          new_app.state.must_equal(@app.state)
          new_app.plan_id.must_equal(@app.plan_id)
          new_app.plan_name.must_equal(@app.plan_name)
          new_app.redirect_url.must_equal 'someurl'
          new_app.version.must_equal(@app.version + 1)

          reloaded_app = Application.load(@app.service_id, @app.id)

          new_app.redirect_url.must_equal(reloaded_app.redirect_url)
          new_app.version.must_equal(reloaded_app.version)
        end

        it 'raises a client-side error when missing mandatory attributes' do
          {service_id: 9000, foo: 'bar', bar: 'foo', id: 6077}.each_cons(2) do |attrs|
            attrs = attrs.to_h
            # note missing service_id, id
            attrs.merge!(state: 'suspended', plan_id: '3066',
              plan_name: 'crappy', redirect_url: 'blah', version: '666')
            lambda do
              Application.save(attrs)
            end.must_raise KeyError # minitest wont catch parent exceptions :/
          end
        end
      end

      describe '#save' do
        before do
          Application.delete(2001, 8011)
          # note that version: 666 should not be saved!
          @app = Application.save service_id: 2001, id: 8011, state: 'suspended',
                                  plan_id: '3066', plan_name: 'crappy', redirect_url: 'blah',
                                  version: '666'
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
          newapp.version.must_equal @app.version
        end

        it 'increases the version' do
          old_version = @app.version
          @app.save
          @app.version.must_equal(old_version + 1)
          newapp = Application.load @app.service_id, @app.id
          newapp.version.must_equal @app.version
        end
      end

      describe 'by_key' do
        before do
          Application.save_id_by_key(2001, 'a_key', 8011)
        end

        describe '.load_id_by_key' do
          it 'returns the app ID linked to the specified service and key' do
            Application.load_id_by_key(2001, 'a_key').must_equal '8011'
          end
        end

        describe '.save_id_by_key' do
          it 'changes the key linked to the app ID and service' do
            Application.load_id_by_key(2001, 'another_key').must_be_nil
            Application.save_id_by_key(2001, 'another_key', 8011).must_equal true
            Application.load_id_by_key(2001, 'another_key').must_equal '8011'
            # clean up this key
            Application.delete_id_by_key(2001, 'another_key')
          end
        end

        describe '.delete_id_by_key' do
          it 'deletes the key linked to the app ID and service' do
            Application.load_id_by_key(2001, 'a_key').must_equal '8011'
            Application.delete_id_by_key(2001, 'a_key')
            Application.load_id_by_key(2001, 'a_key').must_be_nil
          end
        end
      end
    end
  end
end
