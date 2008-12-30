require File.join(File.dirname(__FILE__), 'test_helpers')

require 'rss'

class MapperTest < Test::Unit::TestCase
  
  # simple replacement
  def test_string_map
    data = {
      :skip_this=>'!'
    }
    mapping = {
      :id=>'one',
      :name=>'foo'
    }
    mapper = Solr::Mapper::Base.new(mapping)
    expected = [mapping]
    assert_equal expected, mapper.map(data)
  end
  
  # TODO
  def test_add_and_set_doc_attributes
    assert false
  end
  
  # test enumerable/array mappings
  def test_array_multi_value
    data = {
      :NUMID=>100,
      :type=>:type_val,
      :code=>:code_val
    }
    mapping = {
      :id=>:NUMID,
      :name=>'foo',
      :category=>[:type, :code]
    }
    mapper = Solr::Mapper::Base.new(mapping)
    expected = [{:name=>"foo", :category=>[:type_val, :code_val], :id=>100}]
    assert_equal expected, mapper.map(data)
  end
  
  # test the proc mapping type
  # test that the second arg in the block is a Solr::Mapper
  def test_proc
    data = [{:name=>'-bach;'}]
    mapping = {
      :name=>proc{|d,index|
        assert_equal Fixnum, index.class
        d[:name].gsub(/\W+/, '')
      }
    }
    mapper = Solr::Mapper::Base.new(mapping)
    expected = [{:name=>"bach"}]
    assert_equal expected, mapper.map(data)
  end
  
  def rss_file
    @rss_file ||= File.join(File.dirname(__FILE__), 'ruby-lang.org.rss.xml')
  end
  
  # load an rss feed
  # create a mapping
  # map it and test the fields
  def raw_mapping_rss_docs
    rss = RSS::Parser.parse(File.read(rss_file), false)
    mapping = {
      :channel=>rss.channel.title,
      :url=>rss.channel.link,
      :total=>rss.items.size,
      :title=>proc {|item,index| item.title },
      :link=>proc{|item,index| item.link },
      :published=>proc{|item,index| item.date },
      :description=>proc{|item,index| item.description }
    }
    mapper = Solr::Mapper::Base.new(mapping)
    mapper.map(rss.items)
  end
  
  # load an rss feed
  # create a mapping
  # map it and test the fields
  def rss_mapper_docs
    m = Solr::Mapper::RSS.new
    mapping = {
      :channel=>:'channel.title',
      :url=>:'channel.link',
      :total=>:'items.size',
      :title=>proc {|item,index| item.title },
      :link=>proc {|item,index| item.link },
      :published=>proc {|item,index| item.date },
      :description=>proc {|item,index| item.description }
    }
    m.map(rss_file, mapping)
  end
  
  def test_rss
    [rss_mapper_docs, raw_mapping_rss_docs].each do |docs|
      assert_equal 10, docs.size
      first = docs.first
      # make sure the mapped solr docs have all of the keys from the mapping
      #assert mapping.keys.all?{|mapping_key| first.keys.include?(mapping_key) }
      assert_equal docs.size, docs.first[:total].to_i
      assert_equal Time.parse('Mon Nov 10 09:55:53 -0500 2008'), first[:published]
      assert_equal 'http://www.ruby-lang.org/en/feeds/news.rss/', first[:url]
      assert_equal 'Scotland on Rails 2009', first[:title]
    end
  end
  
end