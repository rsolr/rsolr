# A module that defines the interface and top-level logic for http based connection classes.
module RSolr::Connection::Httpable
  
  attr_reader :opts, :uri
  
  # opts can have:
  #   :url => 'http://localhost:8080/solr'
  def initialize opts={}
    opts[:url] ||= 'http://127.0.0.1:8983/solr'
    @opts = opts
    @uri = URI.parse opts[:url]
  end
  
  # send a request to the connection
  # request '/update', :wt=>:xml, '</commit>'
  def request path, params={}, *extra
    opts = extra[-1].kind_of?(Hash) ? extra.pop : {}
    data = extra[0]
    # force a POST, use the query string as the POST body
    if opts[:method] == :post and data.to_s.empty?
      http_context = self.post(path, hash_to_query(params), {}, {'Content-Type' => 'application/x-www-form-urlencoded'})
    else
      if data
        # standard POST, using "data" as the POST body
        http_context = self.post(path, data, params, {"Content-Type" => 'text/xml; charset=utf-8'})
      else
        # standard GET
        http_context = self.get(path, params)
      end
    end
    raise RSolr::RequestError.new("Solr Response: #{http_context[:message]}") unless http_context[:status_code] == 200
    http_context
  end
  
end