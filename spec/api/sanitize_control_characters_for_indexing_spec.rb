require 'spec_helper'
describe RSolr::SanitizeControlCharactersForIndexing do
  describe '.sanitize_document' do
    it "preserves tabs, newline, and form feed control characters but replaces others with a blank" do
      expect(described_class.sanitize_document({hello: "w\n\foot"})).to eq({ hello: "w\n oot" })
    end
  end
  describe '.sanitize_value' do
    it "preserves tabs, newline, and form feed control characters but replaces others with a blank" do
      given = "a\tb\nc\fd\re"
      expected = "a\tb\nc d\re"
      expect(described_class.sanitize_value(given)).to eq(expected)
    end
  end
end
