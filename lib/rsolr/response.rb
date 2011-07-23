module RSolr::Response
  
  def self.extended base
    if base["response"] && base["response"]["docs"]
      base["response"]["docs"].tap do |d|
        d.extend PaginatedDocSet
        d.per_page = base.request[:params]["rows"]
        d.start = base.request[:params]["start"]
        d.total = base["response"]["numFound"].to_s.to_i
      end
    end
  end
  
  # A response module which gets mixed into the solr ["response"]["docs"] array.
  module PaginatedDocSet

    attr_accessor :start, :per_page, :total

    # Returns the current page calculated from 'rows' and 'start'
    def current_page
      return 1 if start < 1
      per_page_normalized = per_page < 1 ? 1 : per_page
      @current_page ||= (start / per_page_normalized).ceil + 1
    end

    # Calcuates the total pages from 'numFound' and 'rows'
    def total_pages
      @total_pages ||= per_page > 0 ? (total / per_page.to_f).ceil : 1
    end

    # returns the previous page number or 1
    def previous_page
      @previous_page ||= (current_page > 1) ? current_page - 1 : 1
    end

    # returns the next page number or the last
    def next_page
      @next_page ||= (current_page == total_pages) ? total_pages : current_page+1
    end

    def has_next?
      current_page < total_pages
    end

    def has_previous?
      current_page > 1
    end

  end
  
end