
# http://builder.rubyforge.org/
require 'rubygems'
require 'builder'

# The Solr::Message class is the XML generation module for sending updates to Solr.

class Solr::Message
  
  class << self
    
    def xml
      Builder::XmlMarkup.new
    end
    
    # add({})
    # add([{}, {}])
    # add(docs) do |doc|
    #   doc.boost = 10.0
    # end
    def add(data, opts={}, &block)
      data = [data] if data.respond_to?(:each_pair) # if it's a hash, put it in an array
      xml.add(opts) do |add_xml|
        data.each do |item|
          add_xml.doc do |doc_xml|
            # convert keys into strings and perform an alpha sort (easier testing between ruby and jruby)
            # but probably not great for performance? whatever...
            sorted_items = item.inject({}) {|acc,(k,v)| acc.merge({k.to_s=>v})}
            sorted_items.keys.sort.each do |k|
              doc_attrs = {:name=>k}
              yield doc_attrs if block_given?
              doc_xml.field(sorted_items[k], doc_attrs)
            end
          end
        end
      end
    end
    
    def commit(opts={})
      xml.commit(opts)
    end
    
    def optimize(opts={})
      xml.optimize(opts)
    end
    
    def rollback
      xml.rollback
    end
    
    def delete_by_id(ids)
      ids = [ids] unless ids.is_a?(Array)
      xml.delete do |xml|
        ids.each do |id|
          xml.id(id)
        end
      end
    end
    
    def delete_by_query(queries)
      queries = [queries] unless queries.is_a?(Array)
      xml.delete do |xml|
        queries.each do |query|
          xml.query(query)
        end
      end
    end
    
  end
  
end