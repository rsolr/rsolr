require 'net/http'

#
# Connection for standard HTTP Solr server
#
class RSolr::Connection::NetHttp
  
  include RSolr::Connection::Utils
  
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
    raise RSolr::RequestError.new(http_context[:body]) unless http_context[:status_code] == 200
    http_context
  end
  
  protected
  
  def connection
    @connection ||= Net::HTTP.new(@uri.host, @uri.port)
  end
  
  def get path, params={}
    url = self.build_url path, params
    net_http_response = self.connection.get url
    create_http_context net_http_response, url, path, params
  end
  
  def post path, data, params={}, headers={}
    url = self.build_url path, params
    net_http_response = self.connection.post url, data, headers
    create_http_context net_http_response, url, path, params, data, headers
  end
  
  def create_http_context net_http_response, url, path, params, data=nil, headers={}
    full_url = "#{@uri.scheme}://#{@uri.host}"
    full_url += @uri.port ? ":#{@uri.port}" : ''
    full_url += url
    {
      :status_code=>net_http_response.code.to_i,
      :url=>full_url,
      :body=>net_http_response.body,
      :path=>path,
      :params=>params,
      :data=>data,
      :headers=>headers
    }
  end
  
  def build_url path, params={}
    full_path = @uri.path + path
    super full_path, params, @uri.query
  end
  
end