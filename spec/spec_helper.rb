require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

def rsolr
  @rsolr ||= (
    rsolr = RSolr.connect "http://localhost:9999/solr/"
    begin
      rsolr.head('admin')
    rescue
      puts $!.inspect
      puts "\n\n\n****** Start the solr test instance: rake rsolr:solr:start ******\n\n"
      exit(0)
    end
    rsolr
  )
end