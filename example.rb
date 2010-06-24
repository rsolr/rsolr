require 'lib/rsolr'

solr = RSolr.connect "http://localhost:8983/solr/production"

begin
  result = solr.get 'select', :q => '*:*'
  puts result.original_request.inspect
  result['response']['docs'].each do |doc|
    puts doc.inspect
  end
rescue
  puts $!.to_s
end

# solr.commit
# solr.optimize