require_relative './spec_helper'
require_relative './private_endpoints/transaction'

module ThreeScale
  module Core
    describe Transaction do
      before do
        Service.delete_by_id!(service_id)
        Service.save!(provider_key: 'foo', id: service_id)
      end

      describe '.load_all' do
        let(:service_id) { '7575' }
        let(:non_existing_service_id) { service_id.to_i.succ.to_s }

        before do
          Transaction.delete_all(service_id)
        end

        describe 'when there are transactions' do
          let(:first_transaction_time) { Time.new(2015, 1, 1) }
          let(:second_transaction_time) { Time.new(2015, 1, 2) }
          let(:test_transactions) do
            transactions = []
            transactions << { application_id: 'first_test_application',
                              usage: 'first_usage',
                              timestamp: first_transaction_time.to_s }
            transactions << { application_id: 'second_test_application',
                              usage: 'second_usage',
                              timestamp: second_transaction_time.to_s }
          end

          before do
            Transaction.save(service_id, test_transactions)
          end

          it 'returns a collection with the transactions' do
            transactions = Transaction.load_all(service_id)

            transactions.total.must_equal test_transactions.size
            transactions.size.must_equal test_transactions.size

            latest_transaction = transactions[0]
            latest_transaction.application_id.must_equal test_transactions[1][:application_id]
            latest_transaction.usage.must_equal test_transactions[1][:usage]
            latest_transaction.timestamp.must_equal second_transaction_time

            previous_transaction = transactions[1]
            previous_transaction.application_id.must_equal test_transactions[0][:application_id]
            previous_transaction.usage.must_equal test_transactions[0][:usage]
            previous_transaction.timestamp.must_equal first_transaction_time
          end
        end

        describe 'when there are no transactions' do
          it 'returns an empty collection' do
            transactions = Transaction.load_all(service_id)
            transactions.must_be_empty
            transactions.total.must_equal 0
          end
        end

        describe 'with an invalid service ID' do
          it 'returns nil' do
            Transaction.load_all(non_existing_service_id).must_be_nil
          end
        end
      end
    end
  end
end
