require_relative './spec_helper'
require_relative './private_endpoints/event'

module ThreeScale
  module Core
    describe Event do

      let(:example_events) do
        [{ type: 'first_traffic', object: { application_id: 1 } },
         { type: 'first_daily_traffic', object: { application_id: 2 } },
         { type: 'alert', object: { application_id: 3 } }]
      end

      before do
        last_event = Event.load_all.last
        Event.delete_upto(last_event.id) if last_event
      end

      # There are tests that do not delete all the events.
      # We need to define this 'after' in case the last test we execute
      # is one of those.
      after do
        last_event = Event.load_all.last
        Event.delete_upto(last_event.id) if last_event
      end

      describe '.load_all' do
        before do
          Event.save(example_events)
        end

        it 'returns a collection of Events' do
          events = Event.load_all
          events.size.must_equal example_events.size

          events[0].type.must_equal example_events[0][:type]
          events[0].object.must_equal example_events[0][:object]
          events[0].timestamp.wont_be_nil

          events[1].type.must_equal example_events[1][:type]
          events[1].object.must_equal example_events[1][:object]
          events[1].timestamp.wont_be_nil

          events[2].type.must_equal example_events[2][:type]
          events[2].object.must_equal example_events[2][:object]
          events[2].timestamp.wont_be_nil
        end
      end

      describe '.delete' do
        describe 'with an existing id event' do
          before do
            Event.save([example_events.first])
          end

          it 'returns true when deleting an existing event' do
            Event.delete(Event.load_all.last.id).must_equal true
          end
        end

        describe 'with a missing id event' do
          # non_existing_id can be anything, because there are not any events
          # saved at this point.
          let(:non_existing_id) { 1000 }

          it 'returns false when deleting an event with a non-existing id' do
            Event.delete(non_existing_id).must_equal false
          end
        end
      end

      describe '.delete_upto' do
        before do
          Event.save(example_events)
        end

        let(:saved_events) { Event.load_all }

        # Grab the ID of the event before the last one so we can delete all
        # except one. Careful, this let will not work with if the number of
        # saved events is less than 3.
        let(:upto_id) { saved_events[saved_events.size - 2].id }

        it 'returns the number of deleted events' do
          Event.delete_upto(upto_id).must_equal example_events.size - 1
        end
      end
    end
  end
end
