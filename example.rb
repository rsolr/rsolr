require 'lib/rsolr'

solr = RSolr.connect :core => 'development'

solr.post 'catalog', :q=>'coltrane', :fq => "type:Book"

# solr.add :id => "dummy", :name => "blah"
# solr.commit

begin
  response = solr.get('select', :q => '*:*', :wt => :ruby)
  puts response.inspect
rescue
  puts $!.to_s
  puts $!.solr_context[:uri].to_s
end

# solr.delete_by_id "dummy"
# solr.commit
# solr.optimize