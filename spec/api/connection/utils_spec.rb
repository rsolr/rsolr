describe RSolr::Connection::Utils do
  
  # calls #let to set "utils" as a method accessor
  module UtilsHelper
    def self.included base
      base.let(:utils){ nil.extend RSolr::Connection::Utils }
    end
  end
  
  context 'hash_to_query method' do
    
    include UtilsHelper
    
    it "should build a query string from a hash, converting arrays to multi-params and removing nils/emptys" do
      test_params = {
        :z=>'should be whatever',
        :q=>'test',
        :item => [1, 2, 3, nil],
        :nil=>nil
      }
      result = utils.hash_to_query(test_params)
      [/z=should\+be\+whatever/, /q=test/, /item=1/, /item=2/, /item=3/].each do |regexp|
        result.should match(regexp)
      end
      result.split('&').size.should == 5
    end
    
    it 'should escape &' do
      utils.hash_to_query(:fq => "&").should == 'fq=%26'
    end
    
    it 'should convert spaces to +' do
      utils.hash_to_query(:fq => "me and you").should == 'fq=me+and+you'
    end
    
    it 'should escape comlex queries, part 1' do
      my_params = {'fq' => '{!raw f=field_name}crazy+\"field+value'}
      expected = 'fq=%7B%21raw+f%3Dfield_name%7Dcrazy%2B%5C%22field%2Bvalue'
      utils.hash_to_query(my_params).should == expected
    end
    
    it 'should escape comlex queries, part 2' do
      my_params = {'q' => '+popularity:[10 TO *] +section:0'}
      expected = 'q=%2Bpopularity%3A%5B10+TO+%2A%5D+%2Bsection%3A0'
      utils.hash_to_query(my_params).should == expected
    end
    
  end
  
  context 'escape method' do
    
    include UtilsHelper
    
    it 'should escape properly' do
      utils.escape('+').should == '%2B'
      utils.escape('This is a test').should == 'This+is+a+test'
      utils.escape('<>/\\').should == '%3C%3E%2F%5C'
      utils.escape('"').should == '%22'
      utils.escape(':').should == '%3A'
    end
    
    it 'should escape brackets' do
      utils.escape('{').should == '%7B'
      utils.escape('}').should == '%7D'
    end
    
    it 'should escape exclamation marks!' do
      utils.escape('!').should == '%21'
    end
    
  end
  
  context 'build_url method' do
    
    include UtilsHelper
    
    it 'should build correctly' do
      url = utils.build_url '/solr/select', {:q=>'test'}, 'blah=blah'
      url.should == '/solr/select?blah=blah&q=test'
    end
    
  end
  
end