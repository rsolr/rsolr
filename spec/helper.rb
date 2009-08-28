require 'rubygems'
require 'spec'
require 'canned_solr_responses'

require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

RSolr::Adapter::HTTP.send(:include, CannedSolrResponses)

if defined? JRUBY_VERSION
  RSolr::Adapter::Direct.send(:include, CannedSolrResponses)
end