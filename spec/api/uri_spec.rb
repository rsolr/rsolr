require 'spec_helper'
describe "RSolr::Uri" do
  
  let(:uri) { RSolr::Uri }
  
  context '.create' do
    it "returns a URI object" do
      u = uri.create 'http://apache.org'
      expect(u).to be_a_kind_of URI
    end
    it "calls URI.parse" do
      expect(URI).to receive(:parse).twice.and_call_original
      u = uri.create 'http://apache.org'
    end
    it "adds a trailing slash after host if there is none" do
      u = uri.create 'http://apache.org'
      u_str = u.to_s
      size = u_str.size
      expect(u_str[size - 1]).to eq '/'
    end
    it "does not add trailing slash after host if there already is one" do
      u = uri.create 'http://apache.org/'
      u_str = u.to_s
      size = u_str.size
      expect(u_str[size - 2, 2]).to eq 'g/'
    end
    it "adds a trailing slash after path if there is none" do
      u = uri.create 'http://apache.org/lucene'
      u_str = u.to_s
      size = u_str.size
      expect(u_str[size - 1]).to eq '/'
    end
    it "does not add trailing slash after path if there already is one" do
      u = uri.create 'http://apache.org/lucene/'
      u_str = u.to_s
      size = u_str.size
      expect(u_str[size - 2, 2]).to eq 'e/'
    end
    it "does not add trailing slash if there are query params" do
      u = uri.create 'http://apache.org?foo=bar'
      u_str = u.to_s
      size = u_str.size
      expect(u_str[size - 1]).not_to eq '/'
    end
  end

  context '.params_to_solr' do
    it "converts Hash to Solr query string w/o a starting ?" do
      hash = {:q => "gold", :fq => ["mode:one", "level:2"]}
      query = uri.params_to_solr hash
      expect(query[0]).not_to eq(??)
      [/q=gold/, /fq=mode%3Aone/, /fq=level%3A2/].each do |p|
        expect(query).to match p
      end
      expect(query.split('&').size).to eq(3)
    end
    it 'should URL escape &' do
      expect(uri.params_to_solr(:fq => "&")).to eq('fq=%26')
    end

    it 'should convert spaces to +' do
      expect(uri.params_to_solr(:fq => "me and you")).to eq('fq=me+and+you')
    end

    it 'should URL escape complex queries, part 1' do
      my_params = {'fq' => '{!raw f=field_name}crazy+\"field+value'}
      expected = 'fq=%7B%21raw+f%3Dfield_name%7Dcrazy%2B%5C%22field%2Bvalue'
      expect(uri.params_to_solr(my_params)).to eq(expected)
    end

    it 'should URL escape complex queries, part 2' do
      my_params = {'q' => '+popularity:[10 TO *] +section:0'}
      expected = 'q=%2Bpopularity%3A%5B10+TO+*%5D+%2Bsection%3A0'
      expect(uri.params_to_solr(my_params)).to eq(expected)
    end
  end
  
=begin
  # deprecated
  context '.build_param' do
    it "calls URI.encode_www_form_component by default" do
      expect(URI).to receive(:encode_www_form_component).twice
      uri.build_param("foo", "bar")
    end
    it "calls URI.encode_www_form_component if escape arg = true" do
      expect(URI).to receive(:encode_www_form_component).twice
      uri.build_param("foo", "bar", true)
    end
    it "doesn't call URI.encode_www_form_component if escape arg = false" do
      expect(URI).not_to receive(:encode_www_form_component)
      uri.build_param("foo", "bar", false)
    end
  end

  # deprecated
  context ".escape_query_value" do
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
  
  # deprecated
  context '.bytesize' do
    it "calls .bytesize for String" do
      str = "testing"
      expect(str).to receive(:bytesize)
      uri.bytesize(str)
    end
    it "returns the size of a String" do
      expect(uri.bytesize("test")).to eq(4)
    end
  end
=end

end