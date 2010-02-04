begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rsolr"
    gemspec.summary = "A Ruby client for Apache Solr"
    gemspec.description = "RSolr aims to provide a simple and extensible library for working with Solr"
    gemspec.email = "goodieboy@gmail.com"
    gemspec.homepage = "http://github.com/mwmitchell/rsolr"
    gemspec.authors = ["Matt Mitchell"]
    
    gemspec.files = FileList['lib/**/*.rb', 'LICENSE', 'README.rdoc', 'CHANGES']
    
    gemspec.test_files = ['spec/**/*.rb', 'Rakefile', 'tasks/**/*.rake']
    
    gemspec.add_dependency('builder', '>= 2.1.2')
    
    require File.dirname(__FILE__) + '/../lib/rsolr'
    gemspec.version = RSolr::VERSION
    
    now = Time.now
    gemspec.date = "#{now.year}-#{now.month}-#{now.day}"
    
    gemspec.has_rdoc = true
  end
  
  # Jeweler::GemcutterTasks.new
  
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end