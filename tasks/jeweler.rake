require "rubygems"
require "jeweler"

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "rsolr"
  gemspec.summary = "A Ruby client for Apache Solr"
  gemspec.description = "RSolr aims to provide a simple and extensible library for working with Solr"
  gemspec.email = "goodieboy@gmail.com"
  gemspec.homepage = "http://github.com/mwmitchell/rsolr"
  gemspec.authors = ["Matt Mitchell", "Jeremy Hinegardner", "Mat Brown", "Mike Perham", "Nathan Witmer", "Peter Kieltyka", "Randy Souza", "shairon toledo", "shima", "Chris Beer", "Jonathan Rochkind"]
  
  gemspec.files = FileList['lib/**/*.rb', 'LICENSE', 'README.rdoc', 'CHANGES', 'VERSION'].
    exclude("rsolr-direct.rb")
  
  gemspec.test_files = Dir['spec/**/*.rb', 'Rakefile', 'tasks/spec.rake', 'tasks/rdoc.rake']
  
  gemspec.add_dependency('builder', '>= 2.1.2')
  
  #require File.dirname(__FILE__) + '/../lib/rsolr'
  #gemspec.version = RSolr.version
  
  now = Time.now
  
  gemspec.date = now.strftime("%Y-%m-%d")
  
  gemspec.has_rdoc = true
end

Jeweler::RubygemsDotOrgTasks.new