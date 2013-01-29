# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'jeweler'

require './lib/coral_plan.rb'

#-------------------------------------------------------------------------------
# Dependencies

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

#-------------------------------------------------------------------------------
# Gem specification

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name                  = "coral_plan"
  gem.homepage              = "http://github.com/coraltech/ruby-coral_plan"
  gem.rubyforge_project     = 'coral_plan'
  gem.license               = "GPLv3"
  gem.email                 = "adrian.webb@coraltech.net"
  gem.authors               = ["Adrian Webb"]
  gem.summary               = %Q{Provides the ability to create, load, execute, and save execution plans}
  gem.description           = File.read('README.rdoc')
  gem.required_ruby_version = '>= 1.8.1'
  gem.has_rdoc              = true
  gem.rdoc_options << '--title' << 'Coral Execution Plan library' <<
                      '--main' << 'README.rdoc' <<
                      '--line-numbers' 
  
  # Dependencies defined in Gemfile
end

Jeweler::RubygemsDotOrgTasks.new

#-------------------------------------------------------------------------------
# Testing

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

#-------------------------------------------------------------------------------
# Documentation

Rake::RDocTask.new do |rdoc|
  version = Coral::Plan::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "coral_plan #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
