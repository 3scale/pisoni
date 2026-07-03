if ENV['COVERAGE'] && !ENV['COVERAGE'].empty?
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'minitest/autorun'
require 'bundler/setup'
Bundler.require(:default, :development, :test)

SPECIAL_CHARACTERS = "! \"#$%&'()*+,-.:;<=>?@[]^_`{|}~\\/".freeze
