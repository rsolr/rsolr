require 'net/http'

#
# Connection for standard HTTP Solr server
#
class Solr::Adapter::HTTP
  
  class << self
    attr_accessor :http_client_adapter_type
  end
  
  @http_client_adapter_type = :net_http
  
  include Solr::Adapter::CommonMethods
  
  attr_reader :opts
  
  # opts can have:
  #   :url => 'http://localhost:8080/solr'
  #   :select_path => '/the/url/path/to/the/select/handler'
  #   :update_path => '/the/url/path/to/the/update/handler'
  #   :luke_path => '/admin/luke'
  #
  def initialize(opts={}, &block)
    opts[:url]||='http://127.0.0.1:8983/solr'
    @opts = default_options.merge(opts)
  end
  
  def connection
    @connection ||= Solr::HTTP.connect(@opts[:url], self.class.http_client_adapter_type)
  end
  
  # send a request to the connection
  # request '/update', :wt=>:xml, '</commit>'
  def send_request(path, params={}, data=nil)
    data = data.to_xml if data.respond_to?(:to_xml)
    if data
      connection.post(path, data, params, post_headers)
    else
      connection.get(path, params)
    end
  end
  
  protected
  
  # The standard post headers
  def post_headers
    {"Content-Type" => 'text/xml; charset=utf-8'}
  end
  
end