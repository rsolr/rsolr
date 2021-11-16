require 'spec_helper'

RSpec.describe RSolr::Client do
  describe "#connection" do
    it "accepts a timeout parameter it passes to Faraday" do
      client = described_class.new(nil, timeout: 1000)

      expect(client.connection.options[:timeout]).to eq 1000
    end
    it "accepts a deprecated read_timeout" do
      client = nil
      expect do
        client = described_class.new(nil, read_timeout: 1000)
      end.to output(/`read_timeout` is deprecated/).to_stderr

      expect(client.connection.options[:timeout]).to eq 1000
    end
  end
end
