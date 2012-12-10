module ThreeScale
  module Core
    module StorageKeyHelpers
      def encode_key(key)
        key.to_s.tr(' ', '+')
      end

      def decode_key(key)
        key.tr('+', ' ')
      end
    end
  end
end
