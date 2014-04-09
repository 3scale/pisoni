# encoding: utf-8
require 'rake/testtask'
require 'bundler/gem_tasks'

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

ENV['gem_push'] = '0' # don't push to rubygems.org when doing rake release
task geminabox: :release do
  Bundler.with_clean_env do
    exec('gem', 'inabox')
  end
end
