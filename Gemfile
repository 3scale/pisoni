source "http://rubygems.org"
source 'https://localhost'

gemspec

group :test do
  gem 'turn', '~> 0.9.7'
  gem 'minitest'
  gem 'pry'
  # use backend's core-test branch to allow their master to not be always
  # updated with us, so that we can avoid lock-stepping on each other's deps.
  gem '3scale_backend', git: 'git@github.com:3scale/backend.git', branch: 'core-test'
end

group :development do
  gem 'geminabox'
end
