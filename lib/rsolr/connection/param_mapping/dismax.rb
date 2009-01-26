class RSolr::Connection::ParamMapping::Dismax < RSolr::Connection::ParamMapping::Standard
  
  def setup_mappings
    super
    
    mapping_for :alternate_query, :q.alt do |val|
      format_query(val).join(' ')
    end
    
    mapping_for :query_fields, :qf do |val|
      create_boost_query(val)
    end
    
    mapping_for :phrase_fields, :pf do |val|
      create_boost_query(val)
    end
    
    mapping_for :boost_query, :bq do |val|
      format_query(val).join(' ')
    end
    
  end
  
  protected
  
  def create_boost_query(input)
    case input
    when Hash
      qf = []
      input.each_pair do |k,v|
        qf << (v.to_s.empty? ? k : "#{k}^#{v}")
      end
      qf.join(' ')
    when Array
      input.join(' ')
    when String
      input
    end
  end
  
end