require 'uri'

module RSolr::Uri
  
  def create url
    ::URI.parse (url[-1] == '/' || URI.parse(url).query) ? url : "#{url}/"
  end
  
  # Creates a Solr based query string.
  # Keys that have arrays values are set multiple times:
  #   params_to_solr(:q => 'query', :fq => ['a', 'b'])
  # is converted to:
  #   ?q=query&fq=a&fq=b
  # @param [boolean] escape false if no URI escaping is to be performed.  Default true.
  # @return [String] Solr query params as a String, suitable for use in a url
  def params_to_solr(params, escape = true)
    return URI.encode_www_form(params.reject{|k,v| k.to_s.empty? || v.to_s.empty?}) if escape

    # escape = false if we are here
    mapped = params.map do |k, v|
      next if v.to_s.empty?
      if v.class == Array
        params_to_solr(v.map { |x| [k, x] }, false)
      else
        "#{k}=#{v}"
      end
    end
    mapped.compact.join("&")
  end
  
  # Returns a query string param pair as a string.
  # Both key and value are URI escaped, unless third param is false
  # @param [boolean] escape false if no URI escaping is to be performed.  Default true.
  # @deprecated - used to be called from params_to_solr before 2015-02-25
  def build_param(k, v, escape = true)
    warn "[DEPRECATION] `RSolr::Uri.build_param` is deprecated.  Use `URI.encode_www_form_component` or k=v instead."
    escape ? 
      "#{URI.encode_www_form_component(k)}=#{URI.encode_www_form_component(v)}" :
      "#{k}=#{v}"
  end

  # 2015-02  Deprecated: use URI.encode_www_form_component(s)
  #
  # Performs URI escaping so that you can construct proper
  # query strings faster.  Use this rather than the cgi.rb
  # version since it's faster.
  # (Stolen from Rack).
  #  http://www.rubydoc.info/github/rack/rack/URI.encode_www_form_component
  # @deprecated
  def escape_query_value(s)
    warn "[DEPRECATION] `RSolr::Uri.escape_query_value` is deprecated.  Use `URI.encode_www_form_component` instead."
    URI.encode_www_form_component(s)
#    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/u) {
#      '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
#    }.tr(' ', '+')
  end

  # Return the bytesize of String; uses String#size under Ruby 1.8 and
  # String#bytesize under 1.9.
  # @deprecated  as bytesize was only used by escape_query_value which is itself deprecated
  if ''.respond_to?(:bytesize)
    def bytesize(string)
      warn "[DEPRECATION] `RSolr::Uri.bytesize` is deprecated.  Use String.bytesize"
      string.bytesize
    end
  else
    def bytesize(string)
      warn "[DEPRECATION] `RSolr::Uri.bytesize` is deprecated.  Use String.size"
      string.size
    end
  end

  extend self
  
end