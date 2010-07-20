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

    it "with an explicit value" do
      r.element :name, "Fred"
      resulting_json.should == undent(<<-JSON)
      {
        "name": "Fred"
      }
      JSON
    end

  end
  
end
