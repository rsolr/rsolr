require 'libxml'

class RSolr::Message::Adapter::Libxml
  
  def add(documents, attributes = {})
    add_node = new_node('add', attributes)
    for document in documents
      add_node << doc_node = new_node('doc', document.attrs)
      for field in document.fields
        doc_node << field_node = new_node('field', field.attrs)
        field_node << field.value
      end
    end
    add_node.to_s(:indent => false)
  end

  def delete_by_id(ids)
    delete = new_node('delete')
    for id in Array(ids)
      id_node = new_node('id')
      id_node << id
      delete << id_node
    end
    delete.to_s(:indent => false)
  end

  def delete_by_query(queries)
    delete = new_node('delete')
    for query in Array(queries)
      query_node = new_node('query')
      query_node << query
      delete << query_node
    end
    delete.to_s(:indent => false)
  end

  def optimize(opts)
    new_node('optimize', opts).to_s
  end

  def rollback
    new_node('rollback').to_s
  end

  def commit(opts = {})
    new_node('commit', opts).to_s
  end

  private

  def new_node(name, opts = {})
    node = LibXML::XML::Node.new(name)
    opts.each_pair do |attr, value|
      node[attr.to_s] = value.to_s
    end
    node
  end
  
end