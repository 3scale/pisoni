# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{3scale_core}
  s.version = "0.2.7"
  s.date = %q{2010-09-28}

  s.platform = Gem::Platform::RUBY
  s.authors = ["Adam Cig\303\241nek"]
  s.email = %q{adam@3scale.net}
  s.homepage = %q{http://www.3scale.net}
  s.summary = %q{3scale web service management system core libraries}
  s.description = %q{This gem provides core libraries for 3scale systems.}

  # s.required_rubygems_version = ">= 1.3.6"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = %q{1.3.7}

  s.files = Dir.glob("**/*")
  # s.require_path = "lib"
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]

end