describe RSolr::Connection::Utils do
  
  utils = Object.new.instance_eval {extend RSolr::Connection::Utils; self}
  
  context 'hash_to_query method' do
    
    it "should build a query string from a hash" do
      params = {
      :z=>'should be whatever',
      :q=>'test'
      }
      result = utils.hash_to_query(params)
      [/z=should\+be\+whatever/, /q=test/].each do |regexp|
        result.should match(regexp)
      end
      result.split('&').size.should == params.values.size
    end
    
    it 'should transform array values into multiple query params' do
      params = {:name=>['me','you','them','us']}
      result = utils.hash_to_query params
      [/name=me/, /name=you/, /name=them/, /me=us/].each do |regexp|
        result.should match(regexp)
      end
      result.split('&').size.should == params[:name].size
    end
    
    it 'should not include nil values' do
      params = {:name=>['me','you','them','us', nil]}
      result = utils.hash_to_query params
      [/name=me/, /name=you/, /name=them/, /me=us/].each do |regexp|
        result.should match(regexp)
      end
      result.split('&').size.should == (params[:name].size-1)
    end
    
  end
  
  context 'escape method' do
    
  end
  
end