require_relative './spec_helper'
require_relative './private_endpoints/service_error'

module ThreeScale
  module Core
    describe ServiceError do
      let(:service_id) { '7575' }
      let(:non_existing_service_id) { service_id.to_i.succ.to_s }

      describe '.load_all' do
        let(:error_messages) do
          ["application with id=\"boo\" was not found",
           "usage value \"lots\" for metric \"hits\" is invalid",
           "metric \"foo\" is invalid",
           "provider key \"test_app\" is invalid"]
        end

        before do
          Service.delete_by_id!(service_id)
          Service.save!(provider_key: 'foo', id: service_id)
          ServiceError.delete_all(service_id)
          ServiceError.save(service_id, error_messages)
        end

        describe 'without using pagination' do
          it 'returns a collection with the correct size and a total' do
            errors = ServiceError.load_all(service_id)
            errors.size.must_equal error_messages.size
            errors.total.must_equal error_messages.size
            errors.map(&:message).must_equal error_messages.reverse
          end
        end

        describe 'specifying page and per_page' do
          let(:page) { 2 }
          let(:per_page) { 2 }
          let(:first_err_in_page) do
            # Need to reverse because the last message to be saved is the first
            # that we get when loading the messages
            error_messages.reverse[per_page*(page - 1)]
          end
          let(:second_err_in_page) do
            error_messages.reverse[per_page*(page - 1) + 1]
          end

          it 'returns per_page results and the errors of the page specified' do
            service_errors = ServiceError.load_all(
                service_id, { page: page, per_page: per_page })
            service_errors.size.must_equal per_page
            service_errors.total.must_equal error_messages.size

            service_errors[0].message.must_equal first_err_in_page
            service_errors[0].timestamp.must_be_instance_of Time
            service_errors[1].message.must_equal second_err_in_page
            service_errors[1].timestamp.must_be_instance_of Time
          end
        end

        describe 'with a negative per-page value' do
          let(:page) { 1 }
          let(:per_page) { -1 }
          it 'raises exception' do
            lambda {
              ServiceError.load_all(
                  service_id, { page: page, per_page: per_page })
            }.must_raise InvalidPerPage
          end
        end

        describe 'asking for an empty page' do
          let(:page) { 2 }
          let(:per_page) { error_messages.size }
          it 'returns empty collection of errors and correct count' do
            service_errors = ServiceError.load_all(
                service_id, { page: page, per_page: per_page })

            service_errors.size.must_equal 0
            service_errors.total.must_equal error_messages.size
          end
        end

        describe 'asking for the page that contains just the last error' do
          let(:page) { 2 }
          let(:per_page) { error_messages.size - 1 }
          let(:oldest_error) { error_messages.reverse.last }

          it 'returns one error and correct count' do
            service_errors = ServiceError.load_all(
                service_id, { page: page, per_page: per_page })

            service_errors.size.must_equal 1
            service_errors.total.must_equal error_messages.size

            service_errors[0].message.must_equal oldest_error
            service_errors[0].timestamp.must_be_instance_of Time
          end
        end
      end

      describe '.delete_all' do
        before do
          Service.delete_by_id!(service_id)
          Service.save!(provider_key: 'foo', id: service_id)
          ServiceError.delete_all(service_id)
        end

        describe 'with an existing service' do
          it 'returns true' do
            ServiceError.delete_all(service_id).must_equal true
          end

          it 'deletes the errors' do
            service_errors = ServiceError.load_all(service_id)

            service_errors.must_be_empty
            service_errors.total.must_equal 0
          end
        end

        describe 'with a non-existing service' do
          it 'returns false' do
            ServiceError.delete_all(non_existing_service_id).must_equal false
          end
        end
      end
    end
  end
end
