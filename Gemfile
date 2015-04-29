source "http://rubygems.org"
source 'https://localhost'

gemspec

group :test do
  gem 'turn', '~> 0.9.7'
  gem 'minitest'
  # specify a backend version that no longer depends on us (>= 2.25.0)
  gem '3scale_backend', '~> 2.35.0'
  # codeclimate coverage reports
  gem "codeclimate-test-reporter", require: nil
end

group :development, :test do
  # VCR >= 2.9.4, should contain a fix for https://github.com/vcr/vcr/issues/386
  # (Faraday 0.9+ support)
  gem 'vcr', git: 'git://github.com/vcr/vcr',
             ref: '480304be6d73803e6c4a0eb21a4ab4091da558d8'
  gem 'pry',      '~> 0.10.0'
  gem 'pry-doc',  '~> 0.6.0'
  gem 'pry-byebug', '~> 2.0.0'
  gem 'geminabox', '~> 0.12.4', require: false
end
