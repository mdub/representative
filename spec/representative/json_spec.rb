require 'spec_helper'

require "representative/json"

describe Representative::Json do

  def r
    @representative ||= Representative::Json.new(@subject)
  end

  def resulting_json
    r.to_json
  end

  describe "at the top level" do

    describe "#element" do

      describe "with an explicit String value" do

        it "outputs the value as JSON" do
          r.element :name, "Fred"
          resulting_json.should == %{"Fred"\n}
        end

      end

      describe "with an explicit integer value" do

        it "outputs the value as JSON" do
          r.element :age, 36
          resulting_json.should == "36\n"
        end

      end

      describe "with a block" do

        it "outputs an object" do
          r.element :something, Object.new do
          end
          resulting_json.should == "{}\n"
        end

      end

    end

    describe "#list_of" do

      describe "with an explicit value" do

        it "outputs the array as JSON" do
          r.list_of :names, %w(Hewey Dewey Louie)
          resulting_json.should == undent(<<-JSON)
          [
            "Hewey",
            "Dewey",
            "Louie"
          ]
          JSON
        end

      end

    end
    
  end

  describe "within an element block" do
    
    describe "#element" do
      
      it "generates a labelled values" do
        r.element :author, Object.new do
          r.element :name, "Fred"
          r.element :age, 36
        end
        resulting_json.should == undent(<<-JSON)
        {
          "name": "Fred",
          "age": 36
        }
        JSON
      end
      
    end

    describe "without an explicit value" do
      
      it "extracts the value from the current subject" do
        pending
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

end
