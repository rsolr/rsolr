# A module that defines the interface and top-level logic for http based connection classes.
# Httpable provides URL parsing and handles proxy logic.

# TODO: Now that the URI stuff has been pushed out into RSolr::Uri,
# Consider renaming to Requestable, so the direct handler can re-use
# some of this.

module RSolr::Connection::Httpable
  
  attr_reader :opts, :uri, :proxy
  
  # opts can have:
  #   :url => 'http://localhost:8080/solr'
  def initialize opts={}
    opts[:url] ||= 'http://127.0.0.1:8983/solr/'
    @opts = opts
    @uri = new_uri opts[:url]
    @proxy = new_uri opts[:proxy] if opts[:proxy]
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
    extra = extra.dup
    opts = extra[-1].kind_of?(Hash) ? extra.pop : {}
    data = extra[0]
    execute_request create_http_context(path, params, data, opts)
  end
  
  # creates a Hash based "context"
  # which contains all of the information sent to Solr
  # The keys are:
  #   :uri, :data, :headers
  def create_http_context path, params, data = nil, opts={}
    new_uri = @uri.merge_with_params(path, params)
    context = {:uri => new_uri, :data => data}
    if opts[:method] == :post
      raise "Don't send POST data when using :method => :post" unless data.to_s.empty?
      # force a POST, use the query string as the POST body
      context.merge! :data => new_uri.query, :headers => {'Content-Type' => 'application/x-www-form-urlencoded'}
    elsif data
      context.merge! :headers => {'Content-Type' => 'text/xml; charset=utf-8'}
    end
    context
  end
  
  protected
  
  # inspects the context hash and executes the request
  # if data is being sent OR if :method => :post, this is a POST
  # merge the response into the http context
  def execute_request context
    status_code, message, body = context[:data] ? post(context[:uri], context[:data], context[:headers]) : get(context[:uri])
    context.merge :body => body, :status_code => status_code, :message => message
  end
  
  # creates a new (modified) URI object
  def new_uri url
    URI.parse(url).extend RSolr::Uri
  end
  
end