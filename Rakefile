# encoding: utf-8
require 'rake/testtask'
require 'bundler/gem_tasks'

task :default => :test

desc 'Runs tests'
task :test do
  Rake::TestTask.new do |task|
    ENV['THREESCALE_CORE_INTERNAL_API'] ||= 'http://backend:3000/internal/'
    task.test_files = FileList['spec/**/*_spec.rb']
    task.libs = [ 'lib', File.expand_path('.') ]
    task.verbose = true
  end
end

desc 'Creates its own backend instance and runs tests against it'
task :ci do
  # assume we have already set up our own backend if the env variable is set
  if ENV['THREESCALE_CORE_INTERNAL_API'].nil?
    backend = fork do
      ENV['RACK_ENV'] = 'development'
      exec('bundle', 'exec', '3scale_backend', 'start', '-p', '3001')
    end
    sleep 10
    at_exit { Process.kill('INT', backend) }
  end

  # instruct VCR to record http requests/responses
  ENV['FULL_BUILD'] = '1'

  Rake::Task['test'].invoke
end

ENV['gem_push'] = '0' # don't push to rubygems.org when doing rake release
desc 'Releases the gem and pushes it to our geminabox'
task geminabox: :release do
  require 'geminabox_client'
  # because geminabox is smart and tries to guess the gem name from current folder
  gem = GeminaboxClient::GemLocator.find_gem('3scale_core')

  Bundler.with_clean_env do
    exec('gem', 'inabox', gem)
  end
end
