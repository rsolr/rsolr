# A module that defines the interface and top-level logic for http based connection classes.
# Requestable provides URL parsing and handles proxy logic.

# It should probably be re-named to HttpRequest or something?

module RSolr::Connection::Requestable
  
  include RSolr::Connection::Utils
  
  attr_reader :opts, :uri, :proxy
  
  # opts can have:
  #   :url => 'http://localhost:8080/solr'
  def initialize opts={}
    opts[:url] ||= 'http://127.0.0.1:8983/solr'
    @opts = opts
    @uri = URI.parse opts[:url]
    @proxy = URI.parse opts[:proxy] if opts[:proxy]
  end
  
  # send a request to the connection
  # request '/select', :q=>'*:*'
  #
  # request '/update', {:wt=>:xml}, '</commit>'
  # 
  # force a post where the post body is the param query
  # request '/update', "<optimize/>", :method=>:post
  #
  def request path, params={}, *extra
    # be nice
    extra = extra.dup
    opts = extra[-1].kind_of?(Hash) ? extra.pop : {}
    data = extra[0]
    
    context = create_request_context path, params, data, opts
    
    error = nil
    
    begin
      
      if context[:data]
        response = self.post context[:path], context[:data], context[:headers]
      elsif opts[:method] == :post
        response = self.post context[:path], context[:query], context[:headers]
      else
        response = self.get context[:path]
      end
      
      body, status_code, message = response
      
      # merge the response into the http context
      context.merge!(:body => body, :status_code => status_code, :message => message)
      
    rescue
      # throw RequestError?
      context[:message] = $!.to_s
    end
    
    # if no :message but a non-200, throw a "SolrRequestError" ?
    
    error = (context[:message] || "Non-200 Response Status Code") unless context[:status_code] == 200
    
    raise RSolr::RequestError.new("#{error} -> #{context.inspect}") if error
    
    context
  end
  
  # -> should this stuff be in a "ReqResContext" class? ->
  
  def create_request_context path, params, data=nil, opts={}
    context = {:host => base_url, :path => build_url(path), :params => params, :query => hash_to_query(params), :data => data}
    if opts[:method] == :post
      raise "Don't send POST data when using :method => :post" unless data.to_s.empty?
      # force a POST, use the query string as the POST body
      context.merge! :data => hash_to_query(params), :headers => {'Content-Type' => 'application/x-www-form-urlencoded'}
    elsif data
      # standard POST, using "data" as the POST body
      context.merge! :headers => {'Content-Type' => 'text/xml; charset=utf-8'}
    else
      context.merge! :path => build_url(path, params)
    end
    context
  end
  
  # accepts a path/string and optional hash of query params
  def build_url path, params={}
    full_path = @uri.path + path
    super full_path, params, @uri.query
  end
  
  def base_url
    "#{@uri.scheme}://#{@uri.host}" + (@uri.port ? ":#{@uri.port}" : "")
  end

end