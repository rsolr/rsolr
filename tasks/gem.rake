require 'rubygems'
require 'rake/gempackagetask'

namespace :gem do  
  
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
      "examples/direct.rb",
      "examples/http.rb",
      
      "lib/rsolr/connection/direct.rb",
      "lib/rsolr/connection/http.rb",
      "lib/rsolr/connection.rb",
      "lib/rsolr/message.rb",
      
      "lib/rsolr.rb",
      "lib/xout.rb",
      
      "LICENSE",
      "Rakefile",
      "README.rdoc",
      "CHANGES.txt"
    ]
    s.test_files = [
      "test/connection/direct_test.rb",
      "test/connection/http_test.rb",
      "test/connection/test_methods.rb",
      "test/connection/utils_test.rb",
      "test/helper.rb",
      "test/message_test.rb",
      "test/rsolr_test.rb"
    ]
    #s.rdoc_options = ["--main", "README.rdoc"]
    s.extra_rdoc_files = %w(LICENSE Rakefile README.rdoc CHANGES.txt)
  end
  
  Rake::GemPackageTask.new(spec) do |pkg|
      pkg.need_tar = false
  end
  
  # Clean house
  desc 'Clean up tmp files.'
  task :clean do |t|
    FileUtils.rm_rf "doc"
    FileUtils.rm_rf "pkg"
  end
  
end