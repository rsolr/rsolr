require 'uri'

module RSolr::Uri
  
  def create url
    ::URI.parse url[-1] == ?/ ? url : "#{url}/"
  end
  
  # Returns a query string param pair as a string.
  # Both key and value are escaped.
  def build_param(k,v, escape = true)
    escape ? 
      "#{escape_query_value(k)}=#{escape_query_value(v)}" :
      "#{k}=#{v}"
  end

  # Return the bytesize of String; uses String#size under Ruby 1.8 and
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

  # Creates a Solr based query string.
  # Keys that have arrays values are set multiple times:
  #   params_to_solr(:q => 'query', :fq => ['a', 'b'])
  # is converted to:
  #   ?q=query&fq=a&fq=b
  def params_to_solr(params, escape = true)
    mapped = params.map do |k, v|
      next if v.to_s.empty?
      if v.class == Array
        params_to_solr(v.map { |x| [k, x] }, escape)
      else
        build_param k, v, escape
      end
    end
    mapped.compact.join("&")
  end
  
  # Performs URI escaping so that you can construct proper
  # query strings faster.  Use this rather than the cgi.rb
  # version since it's faster.
  # (Stolen from Rack).
  def escape_query_value(s)
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/u) {
      '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
    }.tr(' ', '+')
  end
  
  extend self
  
end