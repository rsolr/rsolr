module RSolr::Uri
  
  attr_accessor :params
  
  def merge_with_params base, params = {}
    n = merge base
    n.extend RSolr::Uri
    n.params = params
    n.query = hash_to_query params
    n
  end
  
  def build_param(k,v)
    "#{escape(k)}=#{escape(v)}"
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
  # version since it's faster.  (Stolen from Rack).
  def escape(s)
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
      #'%'+$1.unpack('H2'*$1.size).join('%').upcase
      '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
    }.tr(' ', '+')
  end
  
end