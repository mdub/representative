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

      describe "without an explicit value" do

        it "extracts the value from the current subject" do
          @author = OpenStruct.new(:name => "Fred", :age => 36)
          r.representing(@author) do
            r.element :name
          end
          resulting_json.should == %{"Fred"\n}
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

      describe "with an explicit array value" do

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

      describe "with a block" do

        it "generates an object for each array element" do
          @authors = [
            OpenStruct.new(:name => "Hewey", :age => 3),
            OpenStruct.new(:name => "Dewey", :age => 4),
            OpenStruct.new(:name => "Louie", :age => 5)
          ]
          r.list_of :authors, @authors do
            r.element :name
            r.element :age
          end
          resulting_json.should == undent(<<-JSON)
          [
            {
              "name": "Hewey",
              "age": 3
            },
            {
              "name": "Dewey",
              "age": 4
            },
            {
              "name": "Louie",
              "age": 5
            }
          ]
          JSON
        end
        
      end

    end

    describe "#comment" do
      
      it "inserts a comment" do
        r.comment "now pay attention"
        resulting_json.should == undent(<<-JSON)
        // now pay attention
        JSON
      end
      
    end
    
  end

  describe "within an element block" do

    describe "#element" do

      it "generates labelled values" do
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

      describe "without an explicit value" do

        it "extracts the value from the current subject" do
          @author = OpenStruct.new(:name => "Fred", :age => 36)
          r.element :author, @author do
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

    describe "#comment" do
      
      it "inserts a comment" do
        @author = OpenStruct.new(:name => "Fred", :age => 36)
        r.element :author, @author do
          r.element :name
          r.comment "age is irrelevant"
          r.element :age
        end
        resulting_json.should == undent(<<-JSON)
        { 
          "name": "Fred",
          // age is irrelevant
          "age": 36
        }
        JSON
      end
      
    end
    
  end

end
