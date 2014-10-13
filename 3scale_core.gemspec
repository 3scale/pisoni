# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require '3scale/core/version'

Gem::Specification.new do |s|
  s.name = %q{3scale_core}
  s.version = ThreeScale::Core::VERSION
  s.date = %q{2011-09-27}

  s.platform = Gem::Platform::RUBY
  s.authors = ["Adam Ciganek", "Tiago Macedo", "Josep M. Pujol", "Wojciech Ogrodowczyk"]
  s.email = %q{wojciech@3scale.net}
  s.homepage = %q{http://www.3scale.net}
  s.summary = %q{3scale web service management system core libraries}
  s.description = %q{This gem provides core libraries for 3scale systems.}

  s.add_dependency 'faraday', '~> 0.8.9'
  s.add_dependency 'json', '~> 1.8.1'

  s.add_development_dependency 'vcr', '2.9.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'redis', '3.0.2'
  s.add_development_dependency 'hiredis', '0.4.5'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]

  s.metadata['allowed_push_host'] = 'https://localhost'
  s.required_ruby_version = '>= 2.1.2'
end
