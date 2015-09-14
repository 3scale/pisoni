module ThreeScale
  module Core
    module APIClient
      class Collection
        include Enumerable
        extend Forwardable

        attr_reader :total

        def initialize(resources=[], total=resources.size)
          @resources = resources
          @total = total
        end

        def_delegators :@resources, :map, :each, :[], :size, :empty?
      end
    end
  end
end