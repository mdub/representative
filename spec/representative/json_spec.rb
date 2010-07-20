require 'spec_helper'

require "representative/json"

describe Representative::Json do

  def r
    @representative ||= Representative::Json.new(@subject)
  end

  def resulting_json
    r.to_json
  end

  describe "with nothing to represent" do

    it "emits an empty object" do
      resulting_json.should == "{\n}\n"
    end

  end

  describe "#element" do

    describe "with an explicit value" do

      it "generates a key-value pair" do
        r.element :name, "Fred"
        resulting_json.should == undent(<<-JSON)
        {
          "name": "Fred"
        }
        JSON
      end

    end

    describe "with an numeric value" do

      it "is represented as a number" do
        r.element :age, 36
        resulting_json.should == undent(<<-JSON)
        {
          "age": 36
        }
        JSON
      end

    end

  end

end
