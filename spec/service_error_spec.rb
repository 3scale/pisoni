require_relative './spec_helper'

module ThreeScale
  module Core
    describe ServiceError do
      describe '.load_all' do

        # We are using VCR because we cannot generate errors manually.
        # The response that we are using contains 4 errors of 4 different types.
        # The next 3 lets need to be set according to the VCR response saved.
        let(:service_id_in_vcr) { SERVICE_ID_IN_VCR }
        let(:errors) {
          errors = [
            { code:'application_not_found',
              message:"application with id=\"boo\" was not found",
              timestamp:'2015-09-14 09:21:58 UTC' },
            { code:'usage_value_invalid',
              message:"usage value \"lots\" for metric \"hits\" is invalid",
              timestamp:'2015-09-14 09:21:58 UTC' },
            { code:'metric_invalid',
              message:"metric \"foo\" is invalid",
              timestamp:'2015-09-14 09:21:58 UTC' },
            { code: 'provider_key_invalid',
              message:"provider key \"test_app\" is invalid",
              timestamp:'2015-09-14 09:21:58 UTC' }]
        }
        let(:errors_saved_in_vcr) { errors.size }

        before do
          Service.delete_by_id!(service_id_in_vcr)
          Service.save!(provider_key: 'foo', id: service_id_in_vcr)
        end

        describe 'without using pagination' do
          it 'returns a collection with the correct size and a total' do
            service_errors = VCR.use_cassette 'load sample errors', record: :none do
              ServiceError.load_all(service_id_in_vcr)
            end
            service_errors.size.must_equal errors_saved_in_vcr
            service_errors.total.must_equal errors_saved_in_vcr
          end
        end

        describe 'specifying page and per_page' do
          let(:page) { 2 }
          let(:per_page) { 2 }
          let(:first_error_in_page) { errors[per_page*(page - 1)] }
          let(:second_error_in_page) { errors[per_page*(page-1) + 1] }
          it 'returns per_page results and the errors of the page specified' do
            service_errors = VCR.use_cassette 'load sample errors specifying page and per_page',
                                              record: :none do
              ServiceError.load_all(service_id_in_vcr, { page: page, per_page: per_page })
            end
            service_errors.size.must_equal per_page
            service_errors.total.must_equal errors_saved_in_vcr

            first_error = service_errors[0]
            first_error.code.must_equal first_error_in_page[:code]
            first_error.message.must_equal first_error_in_page[:message]
            first_error.timestamp.must_equal first_error_in_page[:timestamp]

            second_error = service_errors[1]
            second_error.code.must_equal second_error_in_page[:code]
            second_error.message.must_equal second_error_in_page[:message]
            second_error.timestamp.must_equal second_error_in_page[:timestamp]
          end
        end

        describe 'with a negative per-page value' do
          let(:page) { 1 }
          let(:per_page) { -1 }
          it 'raises exception' do
            lambda {
              VCR.use_cassette 'load sample errors using negative per_page', record: :none do
                ServiceError.load_all(service_id_in_vcr, { page: page, per_page: per_page })
              end
            }.must_raise InvalidPerPage
          end
        end

        describe 'asking for an empty page' do
          let(:page) { 2 }
          let(:per_page) { errors_saved_in_vcr }
          it 'returns empty collection of errors and correct count' do
            service_errors = VCR.use_cassette 'load sample errors asking for empty page',
                                              record: :none do
              ServiceError.load_all(service_id_in_vcr, { page: page, per_page: per_page })
            end
            service_errors.size.must_equal 0
            service_errors.total.must_equal errors_saved_in_vcr
          end
        end

        describe 'asking for the page that contains just the last error' do
          let(:page) { 2 }
          let(:per_page) { errors_saved_in_vcr - 1 }
          let(:last_error) { errors.last }
          it 'returns one error and correct count' do
            service_errors = VCR.use_cassette 'load last page of errors with one',
                                              record: :none do
              ServiceError.load_all(service_id_in_vcr, { page: page, per_page: per_page })
            end
            service_errors.size.must_equal 1
            service_errors.total.must_equal errors_saved_in_vcr

            error = service_errors[0]
            error.code.must_equal last_error[:code]
            error.message.must_equal last_error[:message]
            error.timestamp.must_equal last_error[:timestamp]
          end
        end
      end

      describe '.delete' do
        let(:existing_service_id) { '7575' }
        let(:non_existing_service_id) { existing_service_id.to_i.succ.to_s }

        before do
          Service.delete_by_id!(existing_service_id)
          Service.save!(provider_key: 'foo', id: existing_service_id)
        end

        describe 'with an existing service' do
          it 'returns true' do
            ServiceError.delete(existing_service_id).must_equal true
          end

          it 'deletes the errors' do
            service_errors = ServiceError.load_all(existing_service_id)
            service_errors.must_be_empty
            service_errors.total.must_equal 0
          end
        end

        describe 'with a non-existing service' do
          it 'returns false' do
            ServiceError.delete(non_existing_service_id).must_equal false
          end
        end
      end
    end
  end
end
