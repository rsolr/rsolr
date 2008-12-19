raise "JRuby Required" unless defined?(JRUBY_VERSION)

#c = Solr::HTTP::Adapter::ApacheCommons.new('http://localhost:8983/solr')
#puts c.get('/select', :q=>'*:*')
#puts c.post('/update', '<commit/>', {}, {"Content-Type" => 'text/xml; charset=utf-8'})

require 'java'

proc {|files|
  files.each do |f|
    require File.join(File.dirname(__FILE__), f)
  end
}.call(
  %W(commons-codec-1.3.jar commons-httpclient-3.1.jar commons-logging-1.1.1.jar)
)

require 'uri'

class Solr::HTTP::Adapter::ApacheCommons
  
  include Solr::HTTP::Util
  
  attr :c, :uri
  
  include_package 'org.apache.commons.httpclient'
  include_package 'org.apache.commons.httpclient.methods'
  include_package 'org.apache.commons.httpclient.params.HttpMethodParams'
  include_package 'java.io'
  
  def initialize(url)
    @c = HttpClient.new
    @uri = URI.parse(url)
  end
  
  def get(path, params={})
    method = GetMethod.new(_build_url(path, params))
    @c.executeMethod(method)
    response = method.getResponseBodyAsString
    method.releaseConnection()
    response
  end
  
  def post(path, data, params={}, headers={})
    method = PostMethod.new(_build_url(path, params))
    method.setRequestBody(data)
    headers.each_pair do |k,v|
      method.addRequestHeader(k, v)
    end
    entity = StringRequestEntity.new(data);
    method.setRequestEntity(entity);
    @c.executeMethod(method)
    #response = java.lang.String.new(method.getResponseBody)
    response = method.getResponseBodyAsString
    method.releaseConnection()
    response
  end
  
  protected
  
  def _build_url(path, params={})
    url = @uri.scheme + '://' + @uri.host
    url += ':' + @uri.port.to_s if @uri.port
    url += @uri.path + path
    build_url(url, params, @uri.query)
  end
  
end