require 'net/http'

#
# Connection for standard HTTP Solr server
#
class Solr::Adapter::HTTP
  
  include Solr::Adapter::CommonMethods
  
  attr_accessor :opts, :connection, :url
  
  # opts can have:
  #   :url => 'http://localhost:8080/solr'
  #   :select_path => '/the/url/path/to/the/select/handler'
  #   :update_path => '/the/url/path/to/the/update/handler'
  #   :luke_path => '/admin/luke'
  #
  # If a block is given, the @connection (Net::HTTP) instance is yielded
  def initialize(opts={}, &block)
    opts[:url]||='http://127.0.0.1:8983/solr'
    @url = URI.parse(opts[:url])
    @connection = Net::HTTP.new(@url.host, @url.port)
    yield @connection if block_given?
    @opts = default_options.merge(opts)
  end
  
  # send a request to the connection
  # request '/update', :wt=>:xml, '</commit>'
  def send_request(request_url_path, params={}, data=nil)
    data = data.to_xml if data.respond_to?(:to_xml)
    full_path = build_url(@url.path + request_url_path, params)
    if data
      response = @connection.post(full_path, data, post_headers)
    else
      response = @connection.get(full_path)
    end
    unless response.code=='200'
      raise Solr::RequestError.new(parse_solr_html_error(response.body))
    end
    response.body
  end
  
  protected
  
  # The standard post headers
  def post_headers
    {"Content-Type" => 'text/xml', 'charset'=>'utf-8'}
  end
  
  # extracts the message from the solr error response
  def parse_solr_html_error(html)
    html.scan(/<pre>(.*)<\/pre>/mi).first.first.gsub(/&lt;/, '<').gsub(/&gt;/, '>') rescue html
  end
  
end