require File.join(File.dirname(__FILE__), '..', 'lib', 'solr')

solr = Solr.connect(:http)

#`cd ../apache-solr-1.3.0/example/exampledocs && ./post.sh ./*.xml`

r = solr.paginate 'ipod', :filters=>{:price=>(0..50)}, :per_page=>2, :page=>1