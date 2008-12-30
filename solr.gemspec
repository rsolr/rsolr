Gem::Specification.new do |s|
  s.name = "solr"
  s.version = "0.5.5"
  s.date = "2008-12-29"
  s.summary = "Ruby client for Apache Solr"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/solr"
  s.description = "solr is a Ruby gem for working with Apache Solr"
  s.has_rdoc = true
  s.authors = ["Matt Mitchell"]
  s.files =  Dir.glob("{lib,examples}/**/*")
  s.test_files =  Dir.glob("test/**/*")
  #s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = %w(LICENSE Rakefile README.rdoc CHANGES.txt)
  s.add_dependency("builder", [">= 2.1.2"])
end