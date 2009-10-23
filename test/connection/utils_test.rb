require 'helper'

class HTTPUtilTest < RSolrBaseTest
  
  class DummyClass
    include RSolr::Connection::Utils
  end
  
  def setup
    @c = DummyClass.new
  end
  
  def test_build_url
    assert_equal '/something', @c.build_url('/something')
    assert_equal '/something?q=Testing', @c.build_url('/something', :q=>'Testing')
    assert_equal '/something?array=1&array=2&array=3', @c.build_url('/something', :array=>[1, 2, 3])
    result = @c.build_url('/something', :q=>'A', :array=>[1, 2, 3])
    assert result=~/^\/something\?/
    assert result=~/q=A/
    assert result=~/array=1/
    assert result=~/array=2/
    assert result=~/array=3/
  end
  
  def test_escape
    assert_equal '%2B', @c.escape('+')
    assert_equal 'This+is+a+test', @c.escape('This is a test')
    assert_equal '%3C%3E%2F%5C', @c.escape('<>/\\')
    assert_equal '%22', @c.escape('"')
    assert_equal '%3A', @c.escape(':')
  end
  
  def test_hash_to_query
    my_params = {
      :z=>'should be whatever',
      :q=>'test',
      :d=>[1, 2, 3, 4],
      :b=>:zxcv,
      :x=>['!', '*', nil]
    }
    result = @c.hash_to_query(my_params)
    assert result=~/z=should\+be\+whatever/
    assert result=~/q=test/
    assert result=~/d=1/
    assert result=~/d=2/
    assert result=~/d=3/
    assert result=~/d=4/
    assert result=~/b=zxcv/
    assert result=~/x=%21/
    assert result=~/x=*/
    assert result=~/x=&?/
  end
  
  def test_ampersand_within_query_value
    my_params = {
      "fq" => "building_facet:\"Green (Humanities & Social Sciences)\""
    }
    expected = 'fq=building_facet%3A%22Green+%28Humanities+%26+Social+Sciences%29%22'
    assert_equal expected, @c.hash_to_query(my_params)
  end
  
  def test_brackets
    assert_equal '%7B', @c.escape('{')
    assert_equal '%7D', @c.escape('}')
  end
  
  def test_exclamation
    assert_equal '%21', @c.escape('!')
  end
  
  def test_complex_solr_query1
    my_params = {'fq' => '{!raw f=field_name}crazy+\"field+value'}
    expected = 'fq=%7B%21raw+f%3Dfield_name%7Dcrazy%2B%5C%22field%2Bvalue'
    assert_equal expected, @c.hash_to_query(my_params)
  end
  
  def test_complex_solr_query2
    my_params = {'q' => '+popularity:[10 TO *] +section:0'}
    expected = 'q=%2Bpopularity%3A%5B10+TO+%2A%5D+%2Bsection%3A0'
    assert_equal expected, @c.hash_to_query(my_params)
  end
  
end