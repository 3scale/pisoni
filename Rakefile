# encoding: utf-8
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |task|
  task.test_files = FileList['test/**/*_test.rb', 'spec/**/*_spec.rb']
  task.libs = [ 'lib', File.expand_path('.') ]
  task.verbose = true
end

task :ci do
  backend = fork do
    ENV['RACK_ENV'] = 'development'
    exec('3scale_backend', 'start', '-p', '3000')
  end

  sleep 20

  at_exit { Process.kill('INT', backend) }

  exit Rake::Task['test'].invoke
end
