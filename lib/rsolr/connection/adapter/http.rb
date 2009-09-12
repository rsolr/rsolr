#
# Connection for standard HTTP Solr server
#
class RSolr::Connection::Adapter::HTTP
  
  include RSolr::HTTPClient::Util
  
  attr_reader :opts
  
  # opts can have:
  #   :url => 'http://localhost:8080/solr'
  def initialize(opts={}, &block)
    opts[:url] ||= 'http://127.0.0.1:8983/solr'
    @opts = opts
  end
  
  def connection
    @connection ||= RSolr::HTTPClient.connect(@opts)
  end
  
  # send a request to the connection
  # request '/update', :wt=>:xml, '</commit>'
  def request(path, params={}, *extra)
    opts = extra[-1].kind_of?(Hash) ? extra.pop : {}
    data = extra[0]
    # force a POST, use the query string as the POST body
    if opts[:method] == :post and data.to_s.empty?
      http_context = connection.post(path, hash_to_query(params), {}, {'Content-Type' => 'application/x-www-form-urlencoded'})
    else
      if data
        # standard POST, using "data" as the POST body
        http_context = connection.post(path, data, params, {"Content-Type" => 'text/xml; charset=utf-8'})
      else
        # standard GET
        http_context = connection.get(path, params)
      end
    end
    raise RSolr::RequestError.new(http_context[:body]) unless http_context[:status_code] == 200
    http_context
  end
  
end