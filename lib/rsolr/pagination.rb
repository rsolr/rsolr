module RSolr::Pagination
  
  def self.extended solr_response
    begin
      d = solr_response['response']['docs']
      d.extend Paginator
      d.per_page = solr_response['responseHeader']['params']['rows'].to_s.to_i
      d.start = solr_response['response']['start'].to_s.to_i
      d.total = solr_response['response']['numFound'].to_s.to_i
    rescue
      raise InvalidSolrResponse
    end
  end
  
  class InvalidSolrResponse < RuntimeError; end
  class NegativePerPageError < RuntimeError; end
  
  def self.page_and_per_page_to_start_and_rows page, per_page
    rows = per_page.to_s.to_i
    raise NegativePerPageError if per_page<0
    page = page.to_s.to_i-1
    page = page < 1 ? 0 : page
    start = page * rows
    [start, rows]
  end
  
  module Paginator
    
    attr_accessor :start, :per_page, :total
    
    # Returns the current page calculated from 'rows' and 'start'
    # WillPaginate hook
    def current_page
      return 1 if self.start < 1
      per_page_normalized = per_page < 1 ? 1 : per_page
      @current_page ||= (start / per_page_normalized).ceil + 1
    end

    # Calcuates the total pages from 'numFound' and 'rows'
    # WillPaginate hook
    def total_pages
      @total_pages ||= per_page > 0 ? (total / per_page.to_f).ceil : 1
    end

    # returns the previous page number or 1
    # WillPaginate hook
    def previous_page
      @previous_page ||= (current_page > 1) ? current_page - 1 : 1
    end

    # returns the next page number or the last
    # WillPaginate hook
    def next_page
      @next_page ||= (current_page == total_pages) ? total_pages : current_page+1
    end

    def has_next?
      @has_next ||= current_page < total_pages
    end

    def has_previous?
      @has_previous ||= current_page > 1
    end
    
  end
  
end