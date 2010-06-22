describe RSolr::Uri do
  
  # calls #let to set "uri" as a method accessor
  module UriHelper
    def self.included base
      base.let(:uri){ RSolr::Uri.parse("http://localhost:8983/solr") }
    end
  end
  
  context 'hash_to_query method' do
    
    include UriHelper
    
    it "should build a query string from a hash, converting arrays to multi-params and removing nils/emptys" do
      test_params = {
        :z=>'should be whatever',
        :q=>'test',
        :item => [1, 2, 3, nil],
        :nil=>nil
      }
      result = uri.hash_to_query(test_params)
      [/z=should\+be\+whatever/, /q=test/, /item=1/, /item=2/, /item=3/].each do |regexp|
        result.should match(regexp)
      end
      result.split('&').size.should == 5
    end
    
    it 'should escape &' do
      uri.hash_to_query(:fq => "&").should == 'fq=%26'
    end
    
    it 'should convert spaces to +' do
      uri.hash_to_query(:fq => "me and you").should == 'fq=me+and+you'
    end
    
    it 'should escape comlex queries, part 1' do
      my_params = {'fq' => '{!raw f=field_name}crazy+\"field+value'}
      expected = 'fq=%7B%21raw+f%3Dfield_name%7Dcrazy%2B%5C%22field%2Bvalue'
      uri.hash_to_query(my_params).should == expected
    end
    
    it 'should escape complex queries, part 2' do
      my_params = {'q' => '+popularity:[10 TO *] +section:0'}
      expected = 'q=%2Bpopularity%3A%5B10+TO+%2A%5D+%2Bsection%3A0'
      uri.hash_to_query(my_params).should == expected
    end
        
  end
  
  context 'escape_query_value method' do
    
    include UriHelper
    
    it 'should escape properly' do
      uri.escape_query_value('+').should == '%2B'
      uri.escape_query_value('This is a test').should == 'This+is+a+test'
      uri.escape_query_value('<>/\\').should == '%3C%3E%2F%5C'
      uri.escape_query_value('"').should == '%22'
      uri.escape_query_value(':').should == '%3A'
    end
    
    it 'should escape brackets' do
      uri.escape_query_value('{').should == '%7B'
      uri.escape_query_value('}').should == '%7D'
    end
    
    it 'should escape exclamation marks!' do
      uri.escape_query_value('!').should == '%21'
    end
    
  end
  
  context 'merge_with_params method' do
    
    include UriHelper
    
    it 'should build correctly' do
      url = uri.merge_with_params 'select', {:q=>'test'}
      url.to_s(true).should == 'http://localhost:8983/solr/select?q=test'
    end
    
  end
  
end
