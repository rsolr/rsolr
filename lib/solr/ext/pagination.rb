#
# To use Ext::Pagination:
#   solr = Solr.connect
#   solr.extend Solr::Ext::Pagination
#
module Solr::Ext::Pagination
  
  module Response
    
    def per_page
      @per_page = params['rows'].to_s.to_i
    end
    
    def current_page
      @current_page = self.per_page > 0 ? ((self.start / self.per_page).ceil) : 1
      @current_page == 0 ? 1 : @current_page
    end
    
    alias :page :current_page
    
    def page_count
      @page_count = self.per_page > 0 ? (self.total / self.per_page.to_f).ceil : 1
    end
    
    alias :pages :page_count
    
  end
  
  # override the class query method
  # manipulate the params
  # call the original query method
  # extend the response if the original response was a Solr::Response::Query
  def query(params)
    calculate_start params
    response = super(params)
    if response.is_a?(Solr::Response::Query)
      response.extend Response
    end
  end
  
  protected
  
  # only used by #query
  # can manipulate :start and :rows by setting :page and :per_page
  def calculate_start(params)
    # allow :per_page to be used as "rows", only if :per_page is set
    params[:rows] = params.delete(:per_page) if params.has_key?(:per_page)
    # :page can be set for pagination
    # if it is, override the :start param
    if params[:page]
      page = params.delete(:page) || 1
      params[:start] = calculate_start_int(page, params[:rows])
    end
  end
  
  # Pass in the page number and the per page number...
  # returns the start value
  def calculate_start_int(page, per_page)
    page=page.to_i
    page = (page <= 0 ? 1 : page)
    (page - 1) * per_page.to_i
  end
  
end