module RSolr::Pagination
  
  module Client
    
    def paginate page, per_page, path, opts = {}
      opts[:params] ||= {}
      values = calculate_start_and_rows(page, per_page)
      opts[:params][:start] = values[0]
      opts[:params][:rows] = values[1]
      send_and_receive path, opts
    end
    
    def method_missing name, *args
      if name.to_s =~ /^paginate_(.+)$/
        paginate args[0], args[1], $1, *args[2..-1]
      else
        super name, *args
      end
    end
    
    def evaluate_ruby_response ruby_string
      result = super ruby_string
      result.extend PaginatedResponse
      result
    end
    
    # figures out the "start" and "rows" Solr params
    # by inspecting the :per_page and :page params.
    def calculate_start_and_rows page, per_page
      per_page ||= 10
      page = page.to_s.to_i-1
      page = page < 1 ? 0 : page
      start = page * per_page
      [start, per_page]
    end
    
  end
  
  module PaginatedResponse
    # TODO: self["responseHeader"]["params"]["rows"]
    # will not be available if omitHeader is false...
    # so, a simple "extend" probably isn't going to cut it.
    def self.extended base
      return unless base["response"] && base["response"]["docs"]
      d = base['response']['docs']
      d.extend PaginatedDocSet
      d.per_page = self["responseHeader"]["params"]["rows"].to_s.to_i rescue 10
      d.start = base["response"]["start"].to_s.to_i
      d.total = base["response"]["numFound"].to_s.to_i
    end
  end
  
  # A response module which gets mixed into the solr ["response"]["docs"] array.
  module PaginatedDocSet

    attr_accessor :start, :per_page, :total

    # Returns the current page calculated from 'rows' and 'start'
    # WillPaginate hook
    def current_page
      return 1 if start < 1
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
      current_page < total_pages
    end

    def has_previous?
      current_page > 1
    end

  end
  
end