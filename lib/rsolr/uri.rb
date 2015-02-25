require 'uri'

module RSolr::Uri
  
  def create url
    ::URI.parse (url[-1] == '/' || URI.parse(url).query) ? url : "#{url}/"
  end
  
  # Returns a query string param pair as a string.
  # Both key and value are URI escaped, unless third param is false
  # @param [boolean] escape false if no URI escaping is to be performed.  Default true.
  def build_param(k, v, escape = true)
    escape ? 
      "#{URI.encode_www_form_component(k)}=#{URI.encode_www_form_component(v)}" :
      "#{k}=#{v}"
  end

  # Creates a Solr based query string.
  # Keys that have arrays values are set multiple times:
  #   params_to_solr(:q => 'query', :fq => ['a', 'b'])
  # is converted to:
  #   ?q=query&fq=a&fq=b
  # @param [boolean] escape false if no URI escaping is to be performed.  Default true.
  # @return [String] Solr query params as a String, suitable for use in a url
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
  # 
  # 2015-02
  # The Rack stuff is from 
  #  http://www.rubydoc.info/github/rack/rack/URI.encode_www_form_component
  # We instead will rely on 
  #  http://ruby-doc.org/stdlib-2.2.0/libdoc/uri/rdoc/URI.html#method-c-encode_www_form_component
  #  which is from the Ruby stdlib.  Hence this method is deprecated.
  # @deprecated
  def escape_query_value(s)
    warn "[DEPRECATION] `escape_query_value` is deprecated.  Please use `URI.encode_www_form_component` instead."
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
      warn "[DEPRECATION] `bytesize` is deprecated.  If you are using it, please provide use case to github.com/rsolr/rsolr as an issue."
      string.bytesize
    end
  else
    def bytesize(string)
      warn "[DEPRECATION] `bytesize` is deprecated.  If you are using it, please provide use case to github.com/rsolr/rsolr as an issue."
      string.size
    end
  end

  extend self
  
end