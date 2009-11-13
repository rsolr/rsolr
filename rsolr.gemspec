Gem::Specification.new do |s|
  s.name = "rsolr"
  s.version = "0.10.0"
  s.date = "2009-11-13"
  s.summary = "A Ruby client for Apache Solr"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/rsolr"
  s.description = "RSolr is a Ruby gem for working with Apache Solr!"
  s.has_rdoc = true
  s.authors = ["Matt Mitchell"]
  
  s.files = [
    "CHANGES.txt",
    
    "java/apache-solr-core-nightly.jar",
    "java/apache-solr-solrj-nightly.jar",
    
    "java/commons-fileupload-1.2.1.jar",
    "java/commons-io-1.4.jar",
    
    "java/lucene-analyzers-2.9-dev.jar",
    "java/lucene-core-2.9-dev.jar",
    "java/lucene-highlighter-2.9-dev.jar",
    "java/lucene-memory-2.9-dev.jar",
    "java/lucene-misc-2.9-dev.jar",
    "java/lucene-queries-2.9-dev.jar",
    "java/lucene-snowball-2.9-dev.jar",
    "java/lucene-spellchecker-2.9-dev.jar",
    
    "java/servlet-api-2.4.jar",
    "java/slf4j-api-1.5.5.jar",
    "java/slf4j-jdk14-1.5.5.jar",
    
    "lib/rsolr/client.rb",
    "lib/rsolr/connection/direct.rb",
    "lib/rsolr/connection/net_http.rb",
    "lib/rsolr/connection.rb",
    "lib/rsolr/message.rb",
    "lib/rsolr/pagination.rb",
    "lib/rsolr.rb",
    "lib/xout.rb",
    "LICENSE",
    "README.rdoc",
    "rsolr.gemspec"
  ]
  
  #s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = %w(LICENSE README.rdoc CHANGES.txt)
end