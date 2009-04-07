require 'rubygems'
require 'spec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

RSolr::Adapter::HTTP.send(:include, CannedSolrResponses)
RSolr::Adapter::Direct.send(:include, CannedSolrResponses)