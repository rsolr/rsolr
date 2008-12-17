require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require File.join(File.dirname(__FILE__), 'lib', 'solr')

namespace :solr do
  
  desc "Starts the HTTP server used for running HTTP connection tests"
  task :start_test_server do
    system "cd apache-solr/example; java -jar start.jar"
  end
  
end

task :default => [:test_units]

desc "Run basic tests"
Rake::TestTask.new("test_units") { |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = true
}

# Clean house
desc 'Clean up tmp files.'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "pkg"
end

# Rdoc
desc 'Generate documentation for the solr-ruby gem.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'Solr-Ruby'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

=begin
spec = Gem::Specification.new do |s|
  s.name = "solr-ruby"
  s.version = Solr::VERSION
  s.author = "Matt Mitchell"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/solr-ruby/wikis/"
  s.platform = Gem::Platform::RUBY
  s.summary = "A Ruby client for Apache Solr"
  s.files = FileList[
    "README.rdoc",
    "LICENSE",
    "Rakefile",
    "{lib,test}/**/*"
  ].to_a
  s.require_path = "lib"
  s.test_files = FileList["test/**/test_*.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  s.rdoc_options << '--line-numbers' << '--inline-source'
  s.requirements << 'rubygems'
  s.requirements << 'builder'
end

# build the package - using github for now
require 'rake/gempackagetask'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
=end