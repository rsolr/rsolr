require 'lib/rsolr'

solr = RSolr.connect "http://localhost:9999/solr"

begin
  result = solr.get 'select', :q => '*:*'
  puts "Data sent to Solr:"
  puts result.original_request.inspect
  puts
  puts "Data returned from Solr:"
  puts result.original_response.inspect
  puts
  puts "response['docs']:"
  result['response']['docs'].each do |doc|
    puts doc.inspect
  end
rescue
  puts $!.to_s
end

# solr.commit
# solr.optimize