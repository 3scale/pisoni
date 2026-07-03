if ENV['COVERAGE'] && !ENV['COVERAGE'].empty?
  require 'simplecov'
  require 'simplecov_json_formatter'
  SimpleCov.start do
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::JSONFormatter,
      SimpleCov::Formatter::HTMLFormatter
    ])
    add_filter '/spec/'
  end
end

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'minitest/autorun'
require 'bundler/setup'
Bundler.require(:default, :development, :test)

SPECIAL_CHARACTERS = "! \"#$%&'()*+,-.:;<=>?@[]^_`{|}~\\/".freeze
