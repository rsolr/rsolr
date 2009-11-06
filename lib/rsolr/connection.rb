module RSolr::Connection
  
  autoload :Direct, 'rsolr/connection/direct'
  autoload :NetHttp, 'rsolr/connection/net_http'
  
  # Helpful utility methods for building queries to a Solr server
  module Utils

    # Performs URI escaping so that you can construct proper
    # query strings faster.  Use this rather than the cgi.rb
    # version since it's faster.  (Stolen from Rack).
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
        #'%'+$1.unpack('H2'*$1.size).join('%').upcase
        '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
      }.tr(' ', '+')
    end
    
    # Return the bytesize of String; uses String#length under Ruby 1.8 and
    # String#bytesize under 1.9.
    if ''.respond_to?(:bytesize)
      def bytesize(string)
        string.bytesize
      end
    else
      def bytesize(string)
        string.size
      end
    end
    
    # creates and returns a url as a string
    # "url" is the base url
    # "params" is an optional hash of GET style query params
    # "string_query" is an extra query string that will be appended to the 
    # result of "url" and "params".
    def build_url url='', params={}, string_query=''
      queries = [string_query, hash_to_query(params)]
      queries.delete_if{|i| i.to_s.empty?}
      url += "?#{queries.join('&')}" unless queries.empty?
      url
    end

    # converts a key value pair to an escaped string:
    # Example:
    # build_param(:id, 1) == "id=1"
    def build_param(k,v)
      "#{escape(k)}=#{escape(v)}"
    end

    #
    # converts hash into URL query string, keys get an alpha sort
    # if a value is an array, the array values get mapped to the same key:
    #   hash_to_query(:q=>'blah', :fq=>['blah', 'blah'], :facet=>{:field=>['location_facet', 'format_facet']})
    # returns:
    #   ?q=blah&fq=blah&fq=blah&facet.field=location_facet&facet.field=format.facet
    #
    # if a value is empty/nil etc., it is not added
    def hash_to_query(params)
      mapped = params.map do |k, v|
        next if v.to_s.empty?
        if v.class == Array
          hash_to_query(v.map { |x| [k, x] })
        else
          build_param k, v
        end
      end
      mapped.compact.join("&")
    end

  end
  
end