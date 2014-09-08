# encoding: utf-8
require 'rake/testtask'
require 'bundler/gem_tasks'

task :default => :test

Rake::TestTask.new do |task|
  ENV['THREESCALE_CORE_INTERNAL_API'] ||= 'http://localhost:3001/internal/'
  task.test_files = FileList['test/**/*_test.rb', 'spec/**/*_spec.rb']
  task.libs = [ 'lib', File.expand_path('.') ]
  task.verbose = true
end

task :ci do
  backend = fork do
    ENV['RACK_ENV'] = 'development'
    exec('3scale_backend', 'start', '-p', '3001')
  end

  sleep 10

  at_exit { Process.kill('INT', backend) }

  ENV['FULL_BUILD'] = '1'

  exit system('rake', 'test')
end

ENV['gem_push'] = '0' # don't push to rubygems.org when doing rake release
task geminabox: :release do
  require 'geminabox_client'
  # because geminabox is smart and tries to guess the gem name from current folder
  gem = GeminaboxClient::GemLocator.find_gem('3scale_core')

  Bundler.with_clean_env do
    exec('gem', 'inabox', gem)
  end
end
