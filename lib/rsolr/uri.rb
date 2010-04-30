# Provides a #parse method for creating a modified URI::HTTP(S) instance.
module RSolr::Uri
  
  def self.parse url
    url << '/' unless url[-1] == ?/
    URI.parse(url).extend RSolr::Uri
  end
  
  # a hash for representing query string params
  attr_accessor :params
  
  # Returns a new URI::HTTP instance
  # based off of the current instance's settings.
  # "base" -- a relative path (string)
  # "params" -- a hash with query string param values which gets passed through #hash_to_query
  def merge_with_params base, params = {}
    n = merge base
    n.extend RSolr::Uri
    n.params = params
    n.query = hash_to_query params
    n
  end
  
  # "decode" -- boolean for determining
  # if return val should be decoded.
  def to_s decode_output = false
    decode_output ? URI.decode(super()) : super()
  end
  
  # Returns a query string param pair as a string.
  # Both key and value are escaped.
  def build_param(k,v)
    "#{escape_query_value(k)}=#{escape_query_value(v)}"
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
  #   hash_to_query(:q => 'query', :fq => ['a', 'b'])
  # is converted to:
  #   ?q=query&fq=a&fq=b
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

  # Performs URI escaping so that you can construct proper
  # query strings faster.  Use this rather than the cgi.rb
  # version since it's faster.
  # (Stolen from Rack).
  def escape_query_value(s)
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
      #'%'+$1.unpack('H2'*$1.size).join('%').upcase
      '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
    }.tr(' ', '+')
  end
  
end