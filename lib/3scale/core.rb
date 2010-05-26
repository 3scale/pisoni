module ThreeScale
  module Core
    autoload :Contract,          '3scale/core/contract'
    autoload :Metric,            '3scale/core/metric'
    autoload :Service,           '3scale/core/service'
    autoload :Storable,          '3scale/core/storable'
    autoload :StorageKeyHelpers, '3scale/core/storage_key_helpers'
    # autoload :UsageLimit,         '3scale/backend/usage_limit'
    

    class << self
      attr_accessor :storage
    end
  end
end
