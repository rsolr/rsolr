require File.join(File.dirname(__FILE__), '..', 'test_helpers')

class ParamMappingTest < RSolrBaseTest
  
  include RSolr::Connection::ParamMapping
  
  def test_standard_simple
    input = {
      :queries=>'a query',
      :filters=>'a filter',
      :page=>1,
      :per_page=>10,
      :phrase_queries=>'a phrase query',
      :phrase_filters=>'a phrase filter',
      :facets=>{
        :fields=>[:one,:two]
      }
    }
    mapper = Standard.new(input)
    output = mapper.map
    
    assert_equal "a query \"a phrase query\"", output[:q]
    assert_equal ["a filter", "\"a phrase filter\""], output[:fq]
    assert_equal 0, output[:start]
    assert_equal 10, output[:rows]
    # facet.field can be specified multiple times, so we need an array
    # the url builder automatically adds multiple params for arrays
    assert_equal [:one, :two], output['facet.field']
  end
  
  def test_standard_complex
    input = {
      :queries=>['a query', {:field=>'value'}, 'blah'],
      :filters=>['a filter', {:filter=>'field'}, 'blah'],
      :phrase_queries=>['a phrase', {:phrase_field=>'phrase value'}],
      :phrase_filters=>{:can_also_be_a=>'hash'}
    }
    mapper = Standard.new(input)
    output = mapper.map
    
    assert_equal "a query field:(value) blah \"a phrase\" phrase_field:(\"phrase value\")", output[:q]
    assert_equal ["a filter", "filter:(field)", "blah", "can_also_be_a:(\"hash\")"], output[:fq]
  end
  
  def test_dismax
    input = {
      :alternate_query=>{:can_be_a_string_hash_or_array=>'OK'},
      :query_fields=>{:a_field_to_boost=>20, :another_field_to_boost=>200},
      :phrase_fields=>{:phrase_field=>20},
      :boost_query=>[{:field_to_use_for_boost_query=>'a'}, 'test']
    }
    mapper = Dismax.new(input)
    output = mapper.map
    assert_equal 'can_be_a_string_hash_or_array:(OK)', output['q.alt']
    assert output[:qf]=~/another_field_to_boost\^200/
    assert output[:qf]=~/a_field_to_boost\^20/
    assert_equal 'phrase_field^20', output[:pf]
    assert_equal 'field_to_use_for_boost_query:(a) test', output[:bq]
  end
  
end