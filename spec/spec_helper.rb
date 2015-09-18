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
Bundler.require(:default, :development, :test)
