# http://builder.rubyforge.org/
require 'rubygems'
require 'builder'

# The Solr::Message class is the XML generation module for sending updates to Solr.

class RSolr::Message
  
  class Document
    
  end
  
  class << self
    
    def xml
      ::Builder::XmlMarkup.new
    end
    
    # add({})
    # add([{}, {}])
    # add(docs) do |doc, doc_attrs, field_attrs, field_value|
    #   doc_attrs[:boost] = 10.0 if doc[:id]==1
    # end
    def add(data, add_attrs={}, &block)
      data = [data] if data.respond_to?(:each_pair) # if it's a hash, put it in an array
      doc_attrs=[]
      xml.add(add_attrs) do |add_node|
        data.each do |item|
          doc_attrs << {}
          field_attrs = []
          field_values = []
          item.each_pair do |field,value|
            field_attrs << {:name => field}
            field_values << value
            yield(item, doc_attrs.last, field_attrs.last, field_values.last) if block_given?
          end
          add_node.doc(doc_attrs.pop) do |doc_node|
            field_attrs.each do |attrs|
              fvalue = field_values.shift
              if fvalue.is_a?(Array)
                puts 'IS ARRAY'
                fvalue.each {|fv| doc_node.field(fv, attrs) }
              else
                doc_node.field(fvalue, attrs)
              end
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