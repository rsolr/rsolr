require 'spec_helper'
describe "RSolr::Uri" do
  
  context "class-level methods" do
    
    let(:uri){ RSolr::Uri }
    
    it "should return a URI object with a trailing slash" do
      u = uri.create 'http://apache.org'
      expect(u.path[0]).to eq(?/)
    end
  
    it "should return the bytesize of a string" do
      expect(uri.bytesize("test")).to eq(4)
    end
  
    it "should convert a solr query string from a hash w/o a starting ?" do
      hash = {:q => "gold", :fq => ["mode:one", "level:2"]}
      query = uri.params_to_solr hash
      expect(query[0]).not_to eq(??)
      [/q=gold/, /fq=mode%3Aone/, /fq=level%3A2/].each do |p|
        expect(query).to match p
      end
      expect(query.split('&').size).to eq(3)
    end
    
    context "escape_query_value" do
      
      it 'should escape &' do
        expect(uri.params_to_solr(:fq => "&")).to eq('fq=%26')
      end

      it 'should convert spaces to +' do
        expect(uri.params_to_solr(:fq => "me and you")).to eq('fq=me+and+you')
      end

      it 'should escape comlex queries, part 1' do
        my_params = {'fq' => '{!raw f=field_name}crazy+\"field+value'}
        expected = 'fq=%7B%21raw+f%3Dfield_name%7Dcrazy%2B%5C%22field%2Bvalue'
        expect(uri.params_to_solr(my_params)).to eq(expected)
      end

      it 'should escape complex queries, part 2' do
        my_params = {'q' => '+popularity:[10 TO *] +section:0'}
        expected = 'q=%2Bpopularity%3A%5B10+TO+%2A%5D+%2Bsection%3A0'
        expect(uri.params_to_solr(my_params)).to eq(expected)
      end
      
      it 'should escape properly' do
        expect(uri.escape_query_value('+')).to eq('%2B')
        expect(uri.escape_query_value('This is a test')).to eq('This+is+a+test')
        expect(uri.escape_query_value('<>/\\')).to eq('%3C%3E%2F%5C')
        expect(uri.escape_query_value('"')).to eq('%22')
        expect(uri.escape_query_value(':')).to eq('%3A')
      end

      it 'should escape brackets' do
        expect(uri.escape_query_value('{')).to eq('%7B')
        expect(uri.escape_query_value('}')).to eq('%7D')
      end

      it 'should escape exclamation marks!' do
        expect(uri.escape_query_value('!')).to eq('%21')
      end
      
    end
    
  end
  
end