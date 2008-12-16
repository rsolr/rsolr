# Must be executed using jruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'solr')

path_to_solr_dist=''

base = File.expand_path( File.dirname(__FILE__) )
dist = File.join(base, '..', 'apache-solr')
home = File.join(dist, 'example', 'solr')

solr = Solr.connect(:direct, :home_dir=>home, :dist_dir=>dist)

#`cd ../apache-solr-1.3.0/example/exampledocs && ./post.sh ./*.xml`

solr.search 'ipod', :filters=>{:price=>(0..50)}, :per_page=>2, :page=>1