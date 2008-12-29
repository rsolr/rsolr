#TODO - this could use the http wrapper stuff instead of open-uri/net::http

require 'rss'
require 'open-uri'

class Solr::Mapper::RSS < Solr::Mapper::Base
  
  attr_reader :rss
  
  # rss_file_or_url is file path or url (see open-uri)
  # override_mapping is an alternate mapping (see Solr::Mapper::Base)
  # returns array of mapped hashes
  def map(rss_file_or_url, override_mapping=nil)
    open(rss_file_or_url) do |feed|
       @rss = RSS::Parser.parse(feed.read, false)
       super(rss.items.collect, override_mapping)
    end
  end
  
  # sends methods chain down into the @rss object
  # example: :'channel.title' == @rss.channel.title
  # if the method chain doesn't exist, the super #source_field_value method is called
  def source_field_value(source, method_path)
    method_path.to_s.split('.').inject(@rss) do |rss, m|
      rss.respond_to?(m) ? rss.send(m.to_sym) : super(source, method_path)
    end
  end
  
end