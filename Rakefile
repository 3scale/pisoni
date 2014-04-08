# encoding: utf-8
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |task|
  task.test_files = FileList['test/**/*_test.rb', 'spec/**/*_spec.rb']
  task.libs = [ 'lib', File.expand_path('.') ]
  task.verbose = true
end
