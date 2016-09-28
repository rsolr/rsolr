require 'spec_helper'

RSpec.describe RSolr::Document do
  describe RSolr::Field do
    describe ".instance" do
      subject { RSolr::Field }

      it "detect class name by value" do
        expect(subject.instance({}, Time.new)).to be_a_kind_of(RSolr::TimeField)
      end

      it "detect class name by option" do
        expect(subject.instance({:type => 'Time'}, nil)).to be_a_kind_of(RSolr::TimeField)
      end

      it "fallback with basic Field" do
        expect(subject.instance({:type => 'UndefinedType'}, nil)).to be_a_kind_of(RSolr::Field)
      end
    end

    describe "#value" do
      it "convert value to string" do
        expect(RSolr::Field.instance({}, 1).value).to eq '1'
      end
    end
  end

  describe RSolr::TimeField do
    it "convert value to string" do
      time_value = Time.utc(2013, 9, 11, 18, 10, 0)
      expect(RSolr::Field.instance({}, time_value).value).to eq '2013-09-11T18:10:00Z'
    end

    it "convert time to UTC" do
      time_value = Time.new(2013, 9, 11, 18, 10, 0, '+02:00')
      expect(RSolr::Field.instance({}, time_value).value).to eq '2013-09-11T16:10:00Z'
    end
  end

  describe RSolr::DateField do
    it "convert value to string" do
      date_value = Date.new(2013, 9, 11)
      expect(RSolr::Field.instance({}, date_value).value).to eq '2013-09-11T00:00:00Z'
    end
  end
end
