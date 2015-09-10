if ENV['COVERAGE'] && !ENV['COVERAGE'].empty?
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

SERVICE_ID_IN_VCR = '1111'

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
    events_uri_regex = /\A\/internal\/events/
    errors_uri_regex = /\/internal\/services\/#{SERVICE_ID_IN_VCR}\/errors\//
    !((URI(request.uri).path =~ events_uri_regex) ||
        (URI(request.uri).path =~ errors_uri_regex))
  end

  # ignore requests to CodeClimate
  c.ignore_hosts 'codeclimate.com'
end
