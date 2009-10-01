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

# rake package

require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = "rsolr"
  s.version = "0.9.6"
  s.date = "2009-09-12"
  s.summary = "A Ruby client for Apache Solr"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/rsolr"
  s.description = "RSolr is a Ruby gem for working with Apache Solr!"
  s.has_rdoc = true
  s.authors = ["Matt Mitchell"]
  
  s.files = [
    "examples/http.rb",
    "examples/direct.rb",
    "lib/rsolr.rb",
    "lib/rsolr/connection/adapter/direct.rb",
    "lib/rsolr/connection/adapter/http.rb",
    "lib/rsolr/connection.rb",
    "lib/rsolr/http_client/adapter/curb.rb",
    "lib/rsolr/http_client/adapter/net_http.rb",
    "lib/rsolr/http_client.rb",
    "lib/rsolr/message/adapter/builder.rb",
    "lib/rsolr/message/adapter/libxml.rb",
    "lib/rsolr/message.rb",
    "LICENSE",
    "Rakefile",
    "README.rdoc",
    "rsolr.gemspec",
    "CHANGES.txt"
  ]
  s.test_files = [
    "test/connection/direct_test.rb",
    "test/connection/http_test.rb",
    "test/connection/test_methods.rb",
    "test/helper.rb",
    "test/http_client/curb_test.rb",
    "test/http_client/net_http_test.rb",
    "test/http_client/test_methods.rb",
    "test/http_client/util_test.rb",
    "test/message_test.rb",
    "test/rsolr_test.rb"
  ]
  #s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = %w(LICENSE Rakefile README.rdoc CHANGES.txt)
  s.add_dependency("builder", [">= 2.1.2"])
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = false
end

desc "Run basic tests"
Rake::TestTask.new("test_units") { |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = true
  t.libs << "test"
}

require 'spec/rake/spectask'

desc "Run specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.libs += ["lib", "spec"]
end

desc 'Run specs' # this task runs each test in its own process
task :specs do
  require 'rubygems'
  require 'facets/more/filelist' unless defined?(FileList)
  files = FileList["**/*_spec.rb"]
  p files.to_a
  files.each do |filename|
    system "cd #{File.dirname(filename)} && ruby #{File.basename(filename)}"
  end
end

desc "Run specs"
Rake::TestTask.new("specs") { |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
  t.warning = true
  t.libs += ["lib", "spec"]
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
  rdoc.title = 'RSolr'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end