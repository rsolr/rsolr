require 'builder'

class RSolr::Message::Adapter::Builder
  
  # shortcut method -> xml = RSolr::Message.xml
  def xml
    ::Builder::XmlMarkup.new
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
  def add(documents, add_attrs={})
    xml.add(add_attrs) do |add_node|
      documents.each do |doc|
        # create doc, passing in fields
        add_node.doc(doc.attrs) do |doc_node|
          doc.fields.each do |field_obj|
            doc_node.field(field_obj.value, field_obj.attrs)
          end
        end
      end
    end
  end

  # generates a <commit/> message
  def commit(opts={})
    xml.commit(opts)
  end

  # generates a <optimize/> message
  def optimize(opts={})
    xml.optimize(opts)
  end

  # generates a <rollback/> message
  def rollback
    xml.rollback
  end

  # generates a <delete><id>ID</id></delete> message
  # "ids" can be a single value or array of values
  def delete_by_id(ids)
    ids = [ids] unless ids.is_a?(Array)
    xml.delete do |xml|
      ids.each do |id|
        xml.id(id)
      end
    end
  end

  # generates a <delete><query>ID</query></delete> message
  # "queries" can be a single value or an array of values
  def delete_by_query(queries)
    queries = [queries] unless queries.is_a?(Array)
    xml.delete do |xml|
      queries.each do |query|
        xml.query(query)
      end
    end
  end

end