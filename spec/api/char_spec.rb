require 'spec_helper'
describe "RSolr::Char" do
  
  let(:char){Object.new.extend RSolr::Char}
  
  # deprecated as of 2015-02, as it is incorrect Solr escaping.
  #  instead, use RSolr.solr_escape
  #  commented out as it gives a mess of deprecation warnings
=begin  
  it 'should escape everything that is not a word with \\' do
    (0..255).each do |ascii|
      chr = ascii.chr
      esc = char.escape(chr)
      if chr =~ /\W/
        expect(esc.to_s).to eq("\\#{chr}")
      else
        expect(esc.to_s).to eq(chr)
      end
    end
  end
=end  
end