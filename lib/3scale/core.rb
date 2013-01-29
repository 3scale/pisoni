require '3scale/core/storage_key_helpers'
require '3scale/core/storable'

require '3scale/core/application'
require '3scale/core/metric'
require '3scale/core/service'
require '3scale/core/usage_limit'
require '3scale/core/user'
require '3scale/core/errors'

module ThreeScale
  module Core
    def self.storage
      raise 'You have to reimplement this method to return a storage instance.'
    end
  end
end
