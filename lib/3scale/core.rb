module ThreeScale
  module Core
    autoload :Contract,          '3scale/core/contract'
    autoload :Metric,            '3scale/core/metric'
    autoload :Service,           '3scale/core/service'
    autoload :Storable,          '3scale/core/storable'
    autoload :StorageKeyHelpers, '3scale/core/storage_key_helpers'
    autoload :UsageLimit,        '3scale/core/usage_limit'
   
    def self.storage
      raise 'You have to reimplement this method to return a storage instance.'
    end
  end
end
