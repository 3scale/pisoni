unless ENV['NO_COVERAGE']
  require 'codeclimate-test-reporter'
  SimpleCov.start do
    formatter ENV['CODECLIMATE_REPO_TOKEN'] ?
      CodeClimate::TestReporter::Formatter :
      SimpleCov::Formatter::HTMLFormatter
    add_filter '/spec/'
  end
end

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'minitest/autorun'
require 'bundler/setup'
require_relative 'vcr_filtered_serializer'

Bundler.require(:default, :development, :test)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :faraday
  #c.debug_logger = File.open('vcr_debug.log', 'w')
  VCRFilteredSerializer.serializer = c.cassette_serializers[:yaml]
  c.cassette_serializers[:filtered] = VCRFilteredSerializer
  c.default_cassette_options = { allow_playback_repeats: true,
                                 serialize_with: :filtered,
                                 match_requests_on: [:method, :path, :query, :body]
                               }
  c.ignore_request do |request|
    !(URI(request.uri).path =~ /\A\/internal\/events/)
  end

  # ignore requests to CodeClimate
  c.ignore_hosts 'codeclimate.com'
end
