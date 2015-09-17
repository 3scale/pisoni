module PrivateEndpoints
  module Transaction
    def save(service_id, transactions)
      api_create(transactions,
                 { uri: transactions_uri(service_id),
                   prefix: :transactions })
    end

    def delete_all(service_id)
      api_delete({}, uri: transactions_uri(service_id))
    end
  end
end

ThreeScale::Core::Transaction.extend PrivateEndpoints::Transaction

