require_relative './spec_helper'

# @note: Cassettes in this spec file are configured to use the record mode 'none'.
# This is because we need to fake the response of backend always with the same
# events because there is no way to "generate" events from Core.

module ThreeScale
  module Core
    describe Event do
      describe '.load_all' do
        it 'returns a collection of Events' do
          events = VCR.use_cassette 'load sample events', record: :none do
            Event.load_all
          end

          events.size.must_equal 5
          events.last.id.must_equal 5
          events.last.timestamp.wont_be_nil
        end
      end

      describe '.delete' do
        describe 'with an existing id event' do
          let(:id) { 1 }

          it 'returns true when deleting an existing event' do
            VCR.use_cassette 'delete sample event', record: :none do
              Event.delete(id)
            end.must_equal true
          end
        end

        describe 'with a missing id event' do
          let(:id) { 1000 }

          it 'returns false when deleting an event with missing id' do
            VCR.use_cassette 'delete a missing id event', record: :none do
              Event.delete(id)
            end.must_equal false
          end
        end
      end

      describe '.delete_upto' do
        let(:upto_id) { 3 }

        it 'returns the number of deleted events' do
          VCR.use_cassette 'delete events up to an existing id', record: :none do
            Event.delete_upto(upto_id)
          end.must_equal 3
        end
      end
    end
  end
end
