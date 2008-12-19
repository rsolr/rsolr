module HTTPTestMethods
  
  URL = 'http://localhost:8983/solr/'
  
  def test_raise_unknown_adapter
    assert_raise Solr::HTTP::UnkownAdapterError do
      c = Solr::HTTP.connect(URL, :blah)
    end
  end
  
  def test_get_response
    response = @c.get('select', :q=>'*:*')
    assert response =~ /name="responseHeader"/
  end
  
  def test_post_response
    post_headers = {"Content-Type" => 'text/xml', 'charset'=>'utf-8'}
    data = '<add><doc><field name="id">1</field></doc></add>'
    response = @c.post('update', data, {}, post_headers)
    assert response=~/name="responseHeader"/
  end
  
end