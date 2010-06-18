require 'lib/rsolr'

solr = RSolr.connect :core => 'development'

puts solr.optimize

begin
  response = solr.get('select', :q => '*:*', :wt => :ruby)
  puts response.inspect
rescue
  puts $!.to_s
  puts $!.solr_context[:uri].to_s
end