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

namespace :license_finder do
  desc 'Check license compliance of dependencies'
  task :check do
    STDOUT.puts "Checking license compliance\n"
    unless system("license_finder --decisions-file=#{File.dirname(__FILE__)}" \
                  "/.dependency_decisions.yml")
      STDERR.puts "\n*** License compliance test failed  ***\n"
      exit 1
    end
  end
end
