class RSolr::Message::Adapters::Builder
  
  def initialize
    require 'builder'
  end
  
  def build &block
    b = ::Builder::XmlMarkup.new(:indent=>0, :margin=>0, :encoding => 'UTF-8')
    b.instruct!
    yield b if block_given?
    b
  end
  
  # generates "add" xml for updating solr
  # "data" can be a hash or an array of hashes.
  # - each hash should be a simple key=>value pair representing a solr doc.
  # If a value is an array, multiple fields will be created.
  #
  # "add_attrs" can be a hash for setting the add xml element attributes.
  # 
  # This method can also accept a block.
  # The value yielded to the block is a Message::Document; for each solr doc in "data".
  # You can set xml element attributes for each "doc" element or individual "field" elements.
  #
  # For example:
  #
  # solr.add({:id=>1, :nickname=>'Tim'}, {:boost=>5.0, :commitWithin=>1.0}) do |doc_msg|
  #   doc_msg.attrs[:boost] = 10.00 # boost the document
  #   nickname = doc_msg.field_by_name(:nickname)
  #   nickname.attrs[:boost] = 20 if nickname.value=='Tim' # boost a field
  # end
  #
  # would result in an add element having the attributes boost="10.0"
  # and a commitWithin="1.0".
  # Each doc element would have a boost="10.0".
  # The "nickname" field would have a boost="20.0"
  # if the doc had a "nickname" field with the value of "Tim".
  #
  def add data, add_attrs={}, &block
    data = [data] unless data.is_a?(Array)
    build do |xml|
      xml.add(add_attrs) do |add_node|
        data.each do |doc|
          doc = RSolr::Message::Document.new(doc) if doc.respond_to?(:each_pair)
          yield doc if block_given?
          doc_method = :doc
          add_node.__send__(doc_method, doc.attrs) do |doc_node|
            doc.fields.each do |field_obj|
              doc_node.field field_obj.value, field_obj.attrs
            end
          end
        end
      end
    end
  end
  
  # generates a <commit/> message
  def commit(opts={})
    build {|xml| xml.commit opts}
  end
  
  # generates a <optimize/> message
  def optimize(opts={})
    build {|xml| xml.optimize opts}
  end
  
  # generates a <rollback/> message
  def rollback opts={}
    build {|xml| xml.rollback opts}
  end
  
  # generates a <delete><id>ID</id></delete> message
  # "ids" can be a single value or array of values
  def delete_by_id(ids)
    ids = [ids] unless ids.is_a?(Array)
    build do |xml|
      id_method = :id
      xml.delete do |delete_node|
        ids.each { |id| delete_node.__send__(id_method, id) }
      end
    end
  end
  
  alias_method :delete_by_ids, :delete_by_id
  
  # generates a <delete><query>ID</query></delete> message
  # "queries" can be a single value or an array of values
  def delete_by_query(queries)
    queries = [queries] unless queries.is_a?(Array)
    build do |xml|
      xml.delete do |delete_node|
        queries.each { |query| delete_node.query query }
      end
    end
  end
  
end