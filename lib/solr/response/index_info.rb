# response for /admin/luke
class Solr::Response::IndexInfo < Solr::Response::Base
  
  attr_reader :index, :directory, :has_deletions, :optimized, :current, :max_doc, :num_docs, :version
  
  alias :has_deletions? :has_deletions
  alias :optimized? :optimized
  alias :current? :current
  
  def initialize(data)
    super(data)
    @index = @data['index']
    @directory = @data['directory']
    @has_deletions = @index['hasDeletions']
    @optimized = @index['optimized']
    @current = @index['current']
    @max_doc = @index['maxDoc']
    @num_docs = @index['numDocs']
    @version = @index['version']
  end
  
end