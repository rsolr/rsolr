require 'spec_helper'
describe "RSolr::Uri" do
  
  context "class-level methods" do
    
    let(:uri){ RSolr::Uri }
    
    it "should return a URI object with a trailing slash" do
      u = uri.create 'http://apache.org'
      u.path[0].should == ?/
    end
  
    it "should return the bytesize of a string" do
      uri.bytesize("test").should == 4
    end
  
    it "should convert a solr query string from a hash w/o a starting ?" do
      hash = {:q => "gold", :fq => ["mode:one", "level:2"]}
      query = uri.params_to_solr hash
      query[0].should_not == ??
      [/q=gold/, /fq=mode%3Aone/, /fq=level%3A2/].each do |p|
        query.should match p
      end
      query.split('&').size.should == 3
    end
    
    context "escape_query_value" do
      
      it 'should escape &' do
        uri.params_to_solr(:fq => "&").should == 'fq=%26'
      end

      it 'should convert spaces to +' do
        uri.params_to_solr(:fq => "me and you").should == 'fq=me+and+you'
      end

      it 'should escape comlex queries, part 1' do
        my_params = {'fq' => '{!raw f=field_name}crazy+\"field+value'}
        expected = 'fq=%7B%21raw+f%3Dfield_name%7Dcrazy%2B%5C%22field%2Bvalue'
        uri.params_to_solr(my_params).should == expected
      end

      it 'should escape complex queries, part 2' do
        my_params = {'q' => '+popularity:[10 TO *] +section:0'}
        expected = 'q=%2Bpopularity%3A%5B10+TO+%2A%5D+%2Bsection%3A0'
        uri.params_to_solr(my_params).should == expected
      end
      
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
    
  end
  
end