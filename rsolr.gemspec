# -*- encoding: utf-8 -*-
$:.push File.expand_path("lib", __FILE__)

require "#{File.dirname(__FILE__)}/lib/rsolr"

now = Time.now

Gem::Specification.new do |s|
  s.name        = "rsolr"
  s.summary     = "A Ruby client for Apache Solr"
  s.description = %q{RSolr aims to provide a simple and extensible library for working with Solr}
  s.version     = RSolr.version
  s.date        = now.strftime("%Y-%m-%d")
  s.authors     = ["Matt Mitchell", "Jeremy Hinegardner", "Mat Brown", "Mike Perham", "Nathan Witmer", "Peter Kieltyka", "Randy Souza", "shairon toledo", "shima", "Chris Beer", "Jonathan Rochkind"]
  s.email       = ["goodieboy@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/rsolr"
  s.rubyforge_project = "rsolr"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end