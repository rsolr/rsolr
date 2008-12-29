Gem::Specification.new do |s|
  s.name = "solr"
  s.version = "0.5.4"
  s.date = "2008-12-29"
  s.summary = "Ruby client for Apache Solr"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/solr"
  s.description = "solr is a Ruby gem for working with Apache Solr"
  s.has_rdoc = true
  s.authors = ["Matt Mitchell"]
  s.files = [
    "examples/http.rb",
    "examples/direct.rb",
    "lib/core_ext.rb",
    "lib/solr.rb",
    "lib/solr/connection/adapter/common_methods.rb",
    "lib/solr/connection/adapter/direct.rb",
    "lib/solr/connection/adapter/http.rb",
    "lib/solr/connection/adapter.rb",
    "lib/solr/connection/base.rb",
    "lib/solr/connection/search_ext.rb",
    "lib/solr/connection.rb",
    "lib/solr/http_client/adapter/curb.rb",
    "lib/solr/http_client/adapter/net_http.rb",
    "lib/solr/http_client/adapter.rb",
    "lib/solr/http_client.rb",
    "lib/solr/indexer.rb",
    "lib/solr/mapper/rss.rb",
    "lib/solr/mapper.rb",
    "lib/solr/message.rb",
    "lib/solr/response/base.rb",
    "lib/solr/response/index_info.rb",
    "lib/solr/response/query.rb",
    "lib/solr/response/update.rb",
    "lib/solr/response.rb",
    "LICENSE",
    "Rakefile",
    "README.rdoc",
    "solr-ruby.gemspec",
    "CHANGES.txt"
  ]
  s.test_files = [
    "test/connection/direct_test.rb",
    "test/connection/http_test.rb",
    "test/connection/test_methods.rb",
    "test/core_ext_test",
    "test/http_client/curb_test.rb",
    "test/http_client/net_http_test.rb",
    "test/http_client/test_methods.rb",
    "test/http_client/util_test.rb",
    "test/indexer.rb",
    "test/mapper_test.rb",
    "test/message_test.rb",
    "test/pagination_test.rb",
    "test/ruby-lang.org.rss.xml",
    "test/solr_test",
    "test/test_helpers.rb",
  ]
  #s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = []
  s.add_dependency("builder", [">= 2.1.2"])
end