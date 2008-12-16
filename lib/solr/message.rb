class Solr::Message
  
  class << self
    
    # add({})
    # add([{}, {}])
    # add(docs) do |doc|
    #   doc.boost = 10.0
    # end
    def add(data, opts={}, &block)
      data = [data] if data.respond_to?(:each_pair) # if it's a hash, put it in an array
      data.inject(Xout.new(:add, opts)) do |add_xml, item|
        doc_xml = add_xml.child(:doc) do |doc_xml|
          # convert keys into strings and perform an alpha sort (easier testing between ruby and jruby)
          # but probably not great for performance? whatever...
          item_s = item.inject({}) {|acc,(k,v)| acc.merge({k.to_s=>v})}
          item_s.keys.sort.each do |k|
            field=doc_xml.child(:field, item_s[k], :name=>k)
          end
        end
        yield doc_xml if block
        add_xml
      end
    end
    
    def commit(opts={})
      Xout.new :commit, opts
    end
    
    def optimize(opts={})
      Xout.new :optimize, opts
    end
    
    def rollback
      Xout.new :rollback
    end
    
    def delete_by_id(ids)
      ids = [ids] unless ids.is_a?(Array)
      ids.inject(Xout.new(:delete)){|xml,id|xml.child(:id, id); xml}
    end
    
    def delete_by_query(queries)
      queries = [queries] unless queries.is_a?(Array)
      queries.inject(Xout.new(:delete)){|xml,q|xml.child(:query, q); xml}
    end
    
  end
  
end