require 'spec_helper'
require 'json_spec'
require 'pry'



describe 'RSolr::JSON' do

  let(:generator){ RSolr::JSON::Generator.new }

  context :add do

     it 'should yield a Document object when #add is called with a block' do
      documents = [{:id=>1, :name=>'sam', :cat=>['cat 1', 'cat 2']}]
      result = generator.add(documents) do |doc|
        doc.field_by_name(:name).attrs[:boost] = 10
        doc.fields.size.should == 3
        doc.fields_by_name(:cat).size.should == 1
      end
      result.should be_json_eql('["cat 1", "cat 2"]').at_path('add/0/cat')
      result.should be_json_eql('10').at_path('add/0/name/boost')
    end

    # add a single hash ("doc")
    it 'should create an add from a hash' do
      data = {
        :id=>"1",
        :name=>'matt'
      }
      result = generator.add(data)
      result.should have_json_path("add")
      result.should have_json_size(1).at_path("add")
      result.should be_json_eql(data.to_json).at_path('add/0')
    end

    # add an array of hashes
    it 'should create many adds from an array of hashes' do
      data = [
        {
          :id=>"1",
          :name=>'matt'
        },
        {
          :id=>"2",
          :name=>'sam'
        }
      ]
      message = generator.add(data)
      message.should have_json_size(2).at_path("add")
    end
  end

  it 'should create multiple fields from array values' do
    data = {
      :id   => 1,
      :name => ['matt1', 'matt2']
    }
    result = generator.add(data)
    result.should be_json_eql('["matt1","matt2"]').at_path('add/0/name')
  end

end
