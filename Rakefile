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
