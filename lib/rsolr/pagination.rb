module RSolr::Pagination
  
  # Calculates the "start" and "rows" Solr params
  # by inspecting the :per_page and :page params.
  def self.calculate_start_and_rows page, per_page
    per_page ||= 10
    page = page.to_s.to_i-1
    page = page < 1 ? 0 : page
    start = page * per_page
    [start, per_page]
  end
  
  # A mixin module for RSolr::Client
  # -- note, this must mixed-in via
  # "extend" on a RSolr::Client instance.
  module Client
    
    # A paginated request method.
    def paginate page, per_page, path, opts = {}
      request_context = build_paginated_request page, per_page, path, opts = {}
      puts request_context.inspect
      execute request_context
    end
    
    # Just like RSolr::Client #build_request
    # but converts the page and per_page
    # arguments into :rows and :start.
    def build_paginated_request page, per_page, path, opts = {}
      opts[:page] = page
      opts[:per_page] = per_page
      opts[:params] ||= {}
      values = RSolr::Pagination.calculate_start_and_rows(page, per_page)
      opts[:params][:start] = values[0]
      opts[:params][:rows] = values[1]
      build_request path, opts
    end
    
    protected
    
    # Checks if the called method starts
    # with "paginate_*" and
    # converts the * to the solr
    # request path. It then calls paginate
    # with the appropriate arguments.
    # If the called method doesn't
    # start with "paginate_",
    # the original/super
    # RSolr::Client #method_missing
    # method is called.
    def method_missing name, *args
      if name.to_s =~ /^paginate_(.+)$/
        paginate args[0], args[1], $1, *args[2..-1]
      else
        super name, *args
      end
    end
    
    # Overrides the RSolr::Client #evaluate_ruby_response method.
    # Calls the original/super
    # RSolr::Client #evaluate_ruby_response method.
    # Mixes in the PaginatedResponse if
    # the request[:page] and request[:per_page]
    # opts are set.
    def evaluate_ruby_response request, response
      result = super request, response
      result.extend(PaginatedResponse) if request[:page] && request[:per_page]
      result
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