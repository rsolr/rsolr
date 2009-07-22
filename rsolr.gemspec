Gem::Specification.new do |s|
  s.name = "rsolr"
  s.version = "0.9.1"
  s.date = "2009-07-22"
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
    "lib/rsolr/adapter/direct.rb",
    "lib/rsolr/adapter/http.rb",
    "lib/rsolr/adapter.rb",
    "lib/rsolr/connection.rb",
    "lib/rsolr/http_client/adapter/curb.rb",
    "lib/rsolr/http_client/adapter/net_http.rb",
    "lib/rsolr/http_client/adapter.rb",
    "lib/rsolr/http_client.rb",
    "lib/rsolr/message/builders/builder.rb",
    "lib/rsolr/message/builders/libxml.rb",
    "lib/rsolr/message/builders.rb",
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