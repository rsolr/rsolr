require File.join(File.dirname(__FILE__), '..', 'lib', 'solr')

solr = Solr.connect(:http, :url=>'http://solrpowr.lib.virginia.edu:8080/solr')

#`cd ../apache-solr-1.3.0/example/exampledocs && ./post.sh ./*.xml`

#spellcheck=true&spellcheck.count=5&rows=10&spellcheck.collate=true&
#fq=library_facet:"Alderman" AND broad_format_facet:"Musical Recording"&
#qt=dismax&
#facet.field=library_facet&
#facet.field=broad_format_facet&
#facet.field=subject_facet&
#facet.field=language_facet&
#facet.field=call_number_facet&
#facet.field=call_number_sub_facet&
#facet.field=region_facet&
#facet.field=collection_facet&
#facet.field=source_facet&
#facet.field=series_title_facet&
#sort=date_received_facet desc&
#spellcheck.dictionary=jarowinkler&
#fl=id,media_resource_id_display,title_display,subtitle_display,date_display,date_received_facet,author_display,creator_display,collection_facet,datafile_name_display,broad_format_facet,location_facet,call_number_display,isbn_display,source_facet,content_model_facet,mint_display,accession_display,thumb_obv_display,thumb_rev_display,year_facet&
#facet.limit=6&
#q.alt=*:*&
#start=0&
#spellcheck.extendedResults=true&
#wt=ruby&
#facet.mincount=1&
#spellcheck.onlyMorePopular=true&
#facet=true

r = solr.search(
  'garrison',
  :filters=>{:library_facet=>'"Alderman"', :region_facet=>'"France"'},
  :fields=>%W(title_display id library_facet broad_format_facet),
  :page=>2,
  :per_page=>10,
  :facet.mincount=>1,
  :facet.limit=>10,
  :facet.sort=>true,
  :facets => [
    {:field => [:library_facet, :region_facet, :subject_facet]},
    #{:query => {:library_facet => '"Alderman"', :broad_format_facet=>'"Musical Recording"'},
  #}
  ],
  :qt=>:dismax
)

=begin
r = solr.search({:title_text=>'"thomas jefferson"'},
  {
    :fields=>[:title_display, :id, :location_facet],
#    :facets=>{
#      :name=>:location_facet, :value=>'Alderman Library Stacks'
#    },
    :per_page=>10, :page=>1
  }
)
=end

puts r.inspect

#r.docs.each do |doc|
#  puts doc.title_display
#end