module Solr::Connection::PaginationExt
  
  # paginate(:page=>1, :per_page=>10, :q=>'*:*')
  def paginate(params)
    required = [:page, :per_page]
    pkeys = params.keys
    raise ':per_page and :page are required' unless required.all?{|rkey| pkeys.include?(rkey) }
    params = params.dup # be nice
    params[:rows] = params.delete(:per_page).to_i
    params[:start] = calculate_start(params.delete(:page).to_i, params[:rows])
    query(params)
  end
  
  protected
  
  def calculate_start(current_page, per_page)
    page = current_page > 0 ? current_page : 1
    (page - 1) * per_page
  end
  
end