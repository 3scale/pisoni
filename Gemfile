source "http://rubygems.org"
source 'https://localhost'

gemspec

group :test do
  gem 'turn', '~> 0.9.7'
  gem 'minitest'
  gem '3scale_backend', '~> 2.23.1'
end

group :development, :test do
  gem 'pry',      '~> 0.10.0'
  gem 'pry-doc',  '~> 0.6.0'
  gem 'pry-byebug', '~> 2.0.0'
  gem 'geminabox', '~> 0.12.4', require: false
end
