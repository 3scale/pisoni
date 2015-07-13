module VCRFilteredSerializer
  require 'time'
  require 'uri'

  class << self
    attr_accessor :serializer

    # remove variable data from all request headers
    def serialize(hash)
      hash['http_interactions'].each do |interaction|
        interaction['request']['headers'].delete 'User-Agent'
        interaction['recorded_at'] = FIXED_TIME
        uri = URI.parse(interaction['request']['uri'])
        uri.hostname = 'localhost'
        uri.port = 3001
        interaction['request']['uri'] = uri.to_s
        interaction['response']['headers']['server'] = [to_s]
      end
      serializer.serialize hash
    end

    def method_missing(*args, &blk)
      serializer.send(*args, &blk)
    end

    def respond_to_missing?(*args)
      serializer.respond_to?(*args)
    end

    private

    FIXED_TIME = Time.gm(1980, 9, 10, 15, 00).httpdate
  end
end
