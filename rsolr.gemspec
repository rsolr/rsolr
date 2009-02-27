Gem::Specification.new do |s|
  s.name = "rsolr"
  s.version = "0.7.1"
  s.date = "2009-01-27"
  s.summary = "A Ruby client for Apache Solr"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/rsolr"
  s.description = "RSolr is a Ruby gem for working with Apache Solr!"
  s.has_rdoc = true
  s.authors = ["Matt Mitchell"]
  s.files = [
    "examples/http.rb",
    "examples/direct.rb",
    "lib/core_ext.rb",
    "lib/mash.rb",
    "lib/rsolr.rb",
    "lib/rsolr/connection/adapter/common_methods.rb",
    "lib/rsolr/connection/adapter/direct.rb",
    "lib/rsolr/connection/adapter/http.rb",
    "lib/rsolr/connection/adapter.rb",
    "lib/rsolr/connection/base.rb",
    "lib/rsolr/connection.rb",
    "lib/rsolr/http_client/adapter/curb.rb",
    "lib/rsolr/http_client/adapter/net_http.rb",
    "lib/rsolr/http_client/adapter.rb",
    "lib/rsolr/http_client.rb",
    "lib/rsolr/indexer.rb",
    "lib/rsolr/message.rb",
    "lib/rsolr/response/base.rb",
    "lib/rsolr/response/index_info.rb",
    "lib/rsolr/response/query.rb",
    "lib/rsolr/response/update.rb",
    "lib/rsolr/response.rb",
    "lib/rsolr/query.rb",
    "LICENSE",
    "Rakefile",
    "README.rdoc",
    "rsolr-ruby.gemspec",
    "CHANGES.txt"
  ]
  s.test_files = [
    "test/connection/direct_test.rb",
    "test/connection/http_test.rb",
    "test/connection/test_methods.rb",
    "test/http_client/curb_test.rb",
    "test/http_client/net_http_test.rb",
    "test/http_client/test_methods.rb",
    "test/http_client/util_test.rb",
    "test/indexer.rb",
    "test/message_test.rb",
    "test/query_helper_test.rb",
    "test/response/base_test.rb",
    "test/response/pagination_test.rb",
    "test/response/query_test.rb",
    "test/rsolr_test",
    "test/ruby-lang.org.rss.xml",
    "test/test_helpers.rb",
  ]
  #s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = %w(LICENSE Rakefile README.rdoc CHANGES.txt)
  s.add_dependency("builder", [">= 2.1.2"])
end