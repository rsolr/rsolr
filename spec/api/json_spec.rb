require 'spec_helper'

RSpec.describe RSolr::JSON do

  let(:generator){ RSolr::JSON::Generator.new }

  context :add do
    # add a single hash ("doc")
    it 'should create an add from a hash' do
      data = {
        :id=>"1",
        :name=>'matt'
      }
      message = JSON.parse(generator.add(data), symbolize_names: true)
      expect(message.length).to eq 1
      expect(message.first).to eq data
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
      message = JSON.parse(generator.add(data), symbolize_names: true)
      expect(message).to eq data
    end
  end

  it 'should create multiple fields from array values' do
    data = {
      :id   => "1",
      :name => ['matt1', 'matt2']
    }
    message = JSON.parse(generator.add(data), symbolize_names: true)
    expect(message.length).to eq 1
    expect(message.first).to eq data
  end

end
