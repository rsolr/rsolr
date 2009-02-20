module RSolr::Ext::Pagination
  
  def map_params(input)
    
    result = super(input)
    
    if per_page = result.delete(:per_page)
      per_page = per_page.to_s.to_i
      result[:rows] = per_page < 0 ? 0 : per_page
    end
    
    if page = result.delete(:page)
      page = page.to_s.to_i
      page = page > 0 ? page : 1
      result[:rows] = ((page - 1) * (result[:rows] || 0))
    end
    
    result
    
  end
  
end