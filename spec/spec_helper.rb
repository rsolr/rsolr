require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

def rsolr
  @rsolr ||= (
    rsolr = RSolr.connect "http://localhost:9999/solr"
    begin
      result = rsolr.head 'admin'
      puts result.response.inspect
    rescue
      puts $!
      # puts $!.request_context.inspect
    end
  )
end

rsolr