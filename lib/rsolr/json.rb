module RSolr::JSON
  class Generator
    def add data, add_attrs = nil
      raise "Unable to use add_attr with JSON serialization" unless add_attrs.nil?
      data = [data] unless data.is_a?(Array)
      data.map do |doc|
        RSolr::Document.new(doc).as_json
      end.to_json
    end

    # generates a commit message
    def commit(opts = {})
      opts ||= {}
      { commit: opts }.to_json
    end

    # generates a optimize message
    def optimize(opts = {})
      opts ||= {}
      { optimize: opts }.to_json
    end

    # generates a rollback message
    def rollback
      { rollback: {} }
    end

    # generates a delete message
    # "ids" can be a single value or array of values
    def delete_by_id(ids)
      { delete: ids }.to_json
    end

    # generates a delete message
    # "queries" can be a single value or an array of values
    def delete_by_query(queries)
      { delete: { query: queries } }
    end
  end
end
