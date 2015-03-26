unless ENV['NO_COVERAGE']
  require 'codeclimate-test-reporter'
  SimpleCov.start do
    formatter ENV['CODECLIMATE_REPO_TOKEN'] ?
      CodeClimate::TestReporter::Formatter :
      SimpleCov::Formatter::HTMLFormatter
    add_filter '/test/'
    add_filter '/spec/'
  end
end

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'bundler/setup'
require 'test/vcr_filtered_serializer'

Bundler.require(:default, :development, :test)

class Test::Unit::TestCase
  include ThreeScale::Core
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :faraday
  #c.debug_logger = File.open('vcr_debug.log', 'w')
  VCRFilteredSerializer.serializer = c.cassette_serializers[:yaml]
  c.cassette_serializers[:filtered] = VCRFilteredSerializer
  full_build = ENV['FULL_BUILD'] == '1'
  c.default_cassette_options = { allow_playback_repeats: true,
                                 record: full_build ? :all : :new_episodes,
                                 serialize_with: :filtered,
                                 match_requests_on: [:method, :path, :query, :body]
                               }
  # ignore requests to CodeClimate
  c.ignore_hosts 'codeclimate.com'
end
