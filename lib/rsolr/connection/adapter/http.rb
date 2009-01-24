#
# Connection for standard HTTP Solr server
#
class RSolr::Connection::Adapter::HTTP
  
  class << self
    attr_accessor :client_adapter
  end
  
  @client_adapter = :net_http
  
  include RSolr::Connection::Adapter::CommonMethods
  
  attr_reader :opts
  
  # opts can have:
  #   :url => 'http://localhost:8080/solr'
  #   :select_path => '/the/url/path/to/the/select/handler'
  #   :update_path => '/the/url/path/to/the/update/handler'
  #   :luke_path => '/admin/luke'
  #
  def initialize(opts={}, &block)
    opts[:url]||='http://127.0.0.1:8983/solr'
    @opts = default_options.merge(opts).to_mash # default_options are coming from RSolr::Connection::Adapter::CommonMethods
  end
  
  def connection
    @connection ||= RSolr::HTTPClient.connect(@opts[:url], self.class.client_adapter)
  end
  
  # send a request to the connection
  # request '/update', :wt=>:xml, '</commit>'
  def send_request(path, params={}, data=nil)
    data = data.to_xml if data.respond_to?(:to_xml)
    if data
      http_context = connection.post(path, data, params, post_headers)
    else
      http_context = connection.get(path, params)
    end
    raise RSolr::RequestError.new(http_context[:body]) unless http_context[:status_code] == 200
    http_context
  end
  
  protected
  
  # The standard post headers
  def post_headers
    {"Content-Type" => 'text/xml; charset=utf-8'}
  end
  
end