require 'lib/rsolr'

solr = RSolr.connect "http://localhost:9999/solr/"

begin
  response = solr.get('select', {:q => '*:*', :wt => :ruby, :fq=>[1, 2]}, {"Content-Type"=>"xml/text"})
  puts response.inspect
rescue
  puts $!.to_s#solr_context.inspect
end

# solr.commit
# solr.optimize