require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

namespace :rsolr do
  
  desc "Starts the HTTP server used for running HTTP connection tests"
  task :start_test_server do
    system "cd apache-solr/example; java -jar start.jar"
  end
  
end

task :default => [:test_units]

desc "Run basic tests"
Rake::TestTask.new("test_units") { |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = true
  t.libs << "test"
}

# Clean house
desc 'Clean up tmp files.'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "pkg"
end

# Rdoc
desc 'Generate documentation for the rsolr gem.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'Solr-Ruby'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end