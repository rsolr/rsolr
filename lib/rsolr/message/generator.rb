class RSolr::Message::Generator
  
  attr_accessor :adapter
  
  def initialize adapter
    @adapter = adapter
  end
  
  def add data, add_attrs={}, &block
    adapter.add data, add_attrs, &block
  end
  
  def commit opts={}
    adapter.commit opts={}
  end
  
  # generates a <optimize/> message
  def optimize(opts={})
    adapter.optimize opts
  end
  
  # generates a <rollback/> message
  def rollback opts={}
    adapter.rollback opts
  end
  
  # generates a <delete><id>ID</id></delete> message
  # "ids" can be a single value or array of values
  def delete_by_id ids
    adapter.delete_by_id ids
  end
  
  alias_method :delete_by_ids, :delete_by_id
  
  # generates a <delete><query>ID</query></delete> message
  # "queries" can be a single value or an array of values
  def delete_by_query(queries)
    adapter.delete_by_query queries
  end
  
end