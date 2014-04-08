# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{3scale_core}
  s.version = "0.7.0"
  s.date = %q{2011-09-27}

  s.platform = Gem::Platform::RUBY
  s.authors = ["Adam Ciganek", "Tiago Macedo", "Josep M. Pujol"]
  s.email = %q{josep@3scale.net tiago@3scale.net}
  s.homepage = %q{http://www.3scale.net}
  s.summary = %q{3scale web service management system core libraries}
  s.description = %q{This gem provides core libraries for 3scale systems.}

  s.add_dependency 'faraday', '~> 0.8.9'
  s.add_dependency 'json', '~> 1.8.1'

  s.add_development_dependency 'vcr', '2.9.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'redis', '3.0.2'
  s.add_development_dependency 'hiredis', '0.4.5'

  s.files = Dir.glob("**/*")
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]
end
