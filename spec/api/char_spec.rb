require 'spec_helper'
describe "RSolr::Char" do
  
  let(:char){Object.new.extend RSolr::Char}
  
  it 'should escape everything that is not a word with \\' do
    (0..255).each do |ascii|
      chr = ascii.chr
      esc = char.escape(chr)
      if chr =~ /\W/
        esc.to_s.should == "\\#{chr}"
      else
        esc.to_s.should == chr
      end
    end
  end
  
end