# encoding: utf-8
require 'rake/testtask'


task :default => :test

Rake::TestTask.new do |task|
  task.test_files = FileList['test/**/*_test.rb']
  task.libs = [ 'lib', File.expand_path('.') ]
  task.verbose = true
end

# TODO: replace by standard .gemspec tight with Bundler
begin
  require 'jeweler'

  Jeweler::Tasks.new do |gemspec|
    gemspec.name     = '3scale_core'
    gemspec.summary  = '3scale web service management system core libraries'
    gemspec.description = 'This gem provides core libraries for 3scale systems.'

    gemspec.email    = 'adam@3scale.net'
    gemspec.homepage = 'http://www.3scale.net'
    gemspec.authors  = ['Adam Cigánek']
  end
  
  # HAX: I want only git:release, nothing else.
  Rake::Task['release'].clear_prerequisites
  task :release => 'git:release'
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
