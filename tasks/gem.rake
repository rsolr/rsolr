require 'rubygems'
require 'rake/gempackagetask'

namespace :gem do  
  
  spec = Gem::Specification.new do |s|
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
      "CHANGES.txt"
    ]
    
    #s.rdoc_options = ["--main", "README.rdoc"]
    s.extra_rdoc_files = %w(LICENSE README.rdoc CHANGES.txt)
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