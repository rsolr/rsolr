#
# NOTE: some of this was borrowed from delsolr ;)
#
module Solr::Ext::Search
  
  def search(query, params={})
    if params[:fields].is_a?(Array)
      params[:fl] = params.delete(:fields).join(' ')
    else
      params[:fl] = params.delete :fields
    end
    fq = build_filters(params.delete(:filters)).join(' ') if params[:filters]
    if params[:fq] and fq
      params[:fq] += " AND #{fq}"
    else
      params[:fq] = fq
    end
    facets = params.delete(:facets) if params[:facets]
    if facets
      if facets.is_a?(Array)
        params << {:facet => true}
        params += build_facets(facets)          
      elsif facets.is_a?(Hash)
        params << {:facet => true}
        params += build_facet(facets)
      elsif facets.is_a?(String)
        params += facets
      else
        raise 'facets must either be a Hash or an Array'
      end
    end
    params[:qt] ||= :dismax
    self.query params
  end
  
  # returns the query param
  def build_query(queries)
    query_string = ''
    case queries
    when String
      query_string = queries
    when Array
      query_string = queries.join(' ')
    when Hash
      query_string_array = []
      queries.each do |k,v|
        if v.is_a?(Array) # add a filter for each value
          v.each do |val|
            query_string_array << "#{k}:#{val}"
          end
        elsif v.is_a?(Range)
          query_string_array << "#{k}:[#{v.min} TO #{v.max}]"
        else
          query_string_array << "#{k}:#{v}"
        end
      end
      query_string = query_string_array.join(' ')
    end
    query_string
  end

  def build_filters(filters)
    params = []
    # handle "ruby-ish" filters
    case filters
    when String
      params << filters
    when Array
      filters.each { |f| params << f }
    when Hash
      filters.each do |k,v|
        if v.is_a?(Array) # add a filter for each value
          v.each do |val|
            params << "#{k}:#{val}"
          end
        elsif v.is_a?(Range)
          params << "#{k}:[#{v.min} TO #{v.max}]"
        else
          params << "#{k}:#{v}"
        end
      end
    end
    params
  end

  def build_facets(facet_array)
    facet_array.inject([]) do |params, facet_hash|
      params.push build_facet(facet_hash)
    end
  end

  def build_facet(facet_hash)
    params = []
    facet_name = facet_hash['name'] || facet_hash[:name]
    facet_hash.each do |k,v|
      # handle some cases specially
      if 'field' == k.to_s
        params << {"facet.field" => v}
      elsif 'query' == k.to_s
        q = build_query("facet.query", v)
        params << q
      elsif ['name', :name].include?(k.to_s)
        # do nothing
      else
        params << {"f.#{facet_hash[:field]}.facet.#{k}" => v}
      end
    end
    params
  end
  
end