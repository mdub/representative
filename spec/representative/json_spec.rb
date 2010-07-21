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
      resulting_json.should == "{}\n"
    end

  end

  describe "#element" do

    describe "with an explicit value" do

      it "generates a named-value" do
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

    describe "following another element" do
      
      it "separates named-values with commas" do
        r.element :name, "Fred"
        r.element :age, 36
        resulting_json.should == undent(<<-JSON)
        {
          "name": "Fred",
          "age": 36
        }
        JSON
      end
      
    end

    describe "with a block" do
      
      it "generates a nested object" do
        @author = OpenStruct.new(:name => "Fred", :age => 36)
        r.element :author, "whatever" do
          r.element :name, "Fred"
        end
        resulting_json.should == undent(<<-JSON)
        { 
          "author": {
            "name": "Fred"
          }
        }
        JSON
      end
      
    end

    describe "without an explicit value" do
      
      it "extracts the value from the current subject" do
        @author = OpenStruct.new(:name => "Fred", :age => 36)
        r.representing @author do
          r.element :name
          r.element :age
        end
        resulting_json.should == undent(<<-JSON)
        { 
          "name": "Fred",
          "age": 36
        }
        JSON
      end
      
    end
    
  end

  describe "#list_of" do

    describe "with an explicit value" do

      it "generates a named array" do
        r.list_of :names, %w(Hewey Dewey Louie)
        resulting_json.should == undent(<<-JSON)
        {
          "names": [
            "Hewey",
            "Dewey",
            "Louie"
          ]
        }
        JSON
      end

    end

  end

end
