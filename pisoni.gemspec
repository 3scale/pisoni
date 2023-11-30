# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require '3scale/core/version'

Gem::Specification.new do |s|
  s.name = 'pisoni'
  s.version = ThreeScale::Core::VERSION
  s.date = Time.now.utc.strftime('%Y-%m-%d')

  s.platform = Gem::Platform::RUBY

  s.authors = ['Alejandro Martinez Ruiz']
  s.email = %w[alex@3scale.net]

  s.homepage = 'https://github.com/3scale/pisoni'
  s.summary = 'Client for the Apisonator internal API for model data'
  s.description = 'Client for the Apisonator internal API for model data.'
  s.license     = 'Apache-2.0'

  s.add_dependency 'faraday', '>= 0.9.1'
  s.add_dependency 'json', '>= 1.8.1'
  s.add_dependency 'injectedlogger', '>= 0.0.13'
  s.add_dependency 'net-http-persistent'

  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split($/).reject do |f| [
                        %r{^\.[^\/]},
                        %r{^script/},
                        %r{^docker/},
                        %r{^mk/},
                      ].any? { |r| r.match f }
                    end
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]

  s.required_ruby_version = '>= 2.6.0'
end
