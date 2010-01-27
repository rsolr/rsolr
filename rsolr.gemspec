Gem::Specification.new do |s|
  
  s.name = "rsolr"
  s.version = "0.11.2"
  s.date = "2010-01-26"
  s.summary = "A Ruby client for Apache Solr"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/rsolr"
  s.description = "RSolr is a Ruby gem for working with Apache Solr!"
  s.has_rdoc = true
  s.authors = ["Matt Mitchell"]
  
  s.files = [
    "CHANGES.txt",
    "lib/rsolr/client.rb",
    "lib/rsolr/connection/direct.rb",
    "lib/rsolr/connection/net_http.rb",
    "lib/rsolr/connection.rb",
    "lib/rsolr/message.rb",
    "lib/rsolr.rb",
    "LICENSE",
    "README.rdoc",
    "rsolr.gemspec"
  ]
  
  #s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = %w(LICENSE README.rdoc CHANGES.txt)
end