Gem::Specification.new do |s|
  s.name = "solr-ruby"
  s.version = "0.5.0"
  s.date = "2008-12-16"
  s.summary = "Ruby client for Apache Solr"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/solr-ruby"
  s.description = "solr-ruby is a Ruby gem for working with Apache Solr"
  s.has_rdoc = true
  s.authors = ["Matt Mitchell"]
  s.files = [
    "examples/http.rb",
    "examples/direct.rb",
    "lib/solr.rb",
    "lib/core_ext.rb",
    "lib/solr/adapter.rb",
    "lib/solr/adapter/common_methods.rb",
    "lib/solr/adapter/direct.rb",
    "lib/solr/adapter/http.rb",
    "lib/solr/connection.rb",
    "lib/solr/connection/base.rb",
    "lib/solr/connection/search_ext.rb",
    "lib/solr/indexer.rb",
    "lib/mapper.rb",
    "lib/mapper/rss.rb",
    "lib/message.rb",
    "lib/response.rb",
    "LICENSE",
    "Rakefile",
    "README.rdoc",
    "solr-ruby.gemspec"
  ]
  s.test_files = [
    "test/adapter_common_methods_test.rb",
    "test/connection_test_methods.rb",
    "test/direct_test.rb",
    "test/ext_pagination_test.rb",
    "test/ext_params_test.rb",
    "test/ext_search_test.rb",
    "test/http_test.rb",
    "test/indexer_test.rb",
    "test/mapper_test.rb",
    "test/message_test.rb",
    "test/ruby-lang.org.rss.xml",
    "test/test_helpers.rb",
  ]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = []
  s.add_dependency("builder", ["> 2.1.2"])
end