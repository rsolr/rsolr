require File.join(File.dirname(__FILE__), '..', 'lib', 'solr')

solr = Solr.connect(:http)
solr.extend Solr::Ext::Pagination
solr.extend Solr::Ext::Search

#`cd ../apache-solr-1.3.0/example/exampledocs && ./post.sh ./*.xml`

r = solr.search 'ipod', :filters=>{:price=>(0..50)}, :per_page=>2, :page=>1