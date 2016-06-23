require 'spec_helper'

require "representative/json"

describe Representative::Json do

  def r(options = {})
    @representative ||= Representative::Json.new(@subject, options)
  end

  def resulting_json
    r.to_json
  end

  describe "at the top level" do

    describe "#element" do

      describe "with an explicit String value" do

        it "outputs the value as JSON" do
          r.element :name, "Fred"
          expect(resulting_json).to eq %{"Fred"\n}
        end

      end

      describe "with an explicit integer value" do

        it "outputs the value as JSON" do
          r.element :age, 36
          expect(resulting_json).to eq "36\n"
        end

      end

      describe "with a nil value" do

        it "generates null" do
          r.element :flavour, nil
          expect(resulting_json).to eq "null\n"
        end

        describe "and a block" do

          it "generates null" do
            r.element :book, nil do
              r.element :author
            end
            expect(resulting_json).to eq "null\n"
          end

        end

      end

      describe "with attributes" do

        describe "and a block" do

          it "generates labelled fields for the attributes" do
            @book = OpenStruct.new(:lang => "fr", :title => "En Edge")
            r.element :book, @book, :lang => :lang do
              r.element :title
            end
            expect(resulting_json).to eq undent(<<-JSON)
            {
              "@lang": "fr",
              "title": "En Edge"
            }
            JSON
          end

        end

        describe "and an explicit value" do

          it "ignores the attributes" do
            r.element :review, "Blah de blah", :lang => "fr"
            expect(resulting_json).to eq undent(<<-JSON)
            "Blah de blah"
            JSON
          end

        end

      end

      describe "without an explicit value" do

        it "extracts the value from the current subject" do
          @author = OpenStruct.new(:name => "Fred", :age => 36)
          r.representing(@author) do
            r.element :name
          end
          expect(resulting_json).to eq %{"Fred"\n}
        end

      end

      describe "with a block" do

        it "outputs an object" do
          r.element :something, Object.new do
          end
          expect(resulting_json).to eq "{}\n"
        end

      end

    end

    describe "#list_of" do

      describe "with an explicit array value" do

        it "outputs the array as JSON" do
          r.list_of :names, %w(Hewey Dewey Louie)
          expect(resulting_json).to eq undent(<<-JSON)
          [
            "Hewey",
            "Dewey",
            "Louie"
          ]
          JSON
        end

      end

      describe "without an explicit value" do

        it "extracts the value from the current subject" do
          @donald = OpenStruct.new(:nephews => %w(Hewey Dewey Louie))
          r.element(:duck, @donald) do
            r.list_of :nephews
          end
          expect(resulting_json).to eq undent(<<-JSON)
          {
            "nephews": [
              "Hewey",
              "Dewey",
              "Louie"
            ]
          }
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
          expect(resulting_json).to eq undent(<<-JSON)
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

      describe "with item attributes" do
        it "adds the attributes with an @ sign to child elements" do
          @authors = [
            OpenStruct.new(:name => "Hewey", :age => 3),
            OpenStruct.new(:name => "Dewey", :age => 4),
            OpenStruct.new(:name => "Louie", :age => 5)
          ]
          r.list_of :authors, @authors, :item_attributes => {:about => lambda{|obj| "#{obj.name} is #{obj.age} years old"}} do
            r.element :name
            r.element :age
          end
          expect(resulting_json).to eq undent(<<-JSON)
          [
            {
              "@about": "Hewey is 3 years old",
              "name": "Hewey",
              "age": 3
            },
            {
              "@about": "Dewey is 4 years old",
              "name": "Dewey",
              "age": 4
            },
            {
              "@about": "Louie is 5 years old",
              "name": "Louie",
              "age": 5
            }
          ]
          JSON
        end
      end

      describe "with list attributes" do
        it "raises an ArgumentError" do
          @authors = []
          expect(-> {
            r.list_of(:authors, @authors, :list_attributes => {}) {}
          }).to raise_exception(ArgumentError)
        end
      end

      describe "with unnecessary arguments" do
        it "raises an ArgumentError" do
          @authors = []
          expect(-> {
            r.list_of(:authors, @authors, :unecessary_arg_should_cause_failure, :item_attributes => {}){}
          }).to raise_exception(ArgumentError)
        end
      end

    end

    describe "#comment" do

      it "inserts a comment" do
        r.comment "now pay attention"
        expect(resulting_json).to eq undent(<<-JSON)
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
        expect(resulting_json).to eq undent(<<-JSON)
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
          expect(resulting_json).to eq undent(<<-JSON)
          {
            "name": "Fred",
            "age": 36
          }
          JSON
        end

      end

    end

    describe "#attribute" do

      it "generates labelled values, with a label prefix" do
        r.element :author, Object.new do
          r.attribute :href, "http://example.com/authors/1"
          r.element :name, "Fred"
        end
        expect(resulting_json).to eq undent(<<-JSON)
        {
          "@href": "http://example.com/authors/1",
          "name": "Fred"
        }
        JSON
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
        expect(resulting_json).to eq undent(<<-JSON)
        {
          "name": "Fred",
          // age is irrelevant
          "age": 36
        }
        JSON
      end

    end

  end

  context "by default" do

    it "does not tranform element names" do
      r.element :user, Object.new do
        r.element :full_name, "Fred Bloggs"
      end
      expect(resulting_json).to eq undent(<<-JSON)
      {
        "full_name": "Fred Bloggs"
      }
      JSON
    end

  end

  context "with naming_strategy :camelcase" do

    it "generates camelCased element and attribute names" do
      @user = OpenStruct.new(:full_name => "Fred Bloggs")
      r(:naming_strategy => :camelcase).element :user, @user do
        r.attribute :alt_url, "http://xyz.com"
        r.element :full_name
      end
      expect(resulting_json).to eq undent(<<-JSON)
      {
        "@altUrl": "http://xyz.com",
        "fullName": "Fred Bloggs"
      }
      JSON
    end

  end

  context "with :indentation option" do

    before do
      @authors = [
        OpenStruct.new(:name => "Hewey", :age => 3),
        OpenStruct.new(:name => "Dewey", :age => 4)
      ]
    end

    context "set to an integer" do

      it "indents the specified number of spaces" do
        r(:indentation => 3).list_of :authors, @authors do
          r.element :name
          r.element :age
        end
        expect(resulting_json).to eq undent(<<-JSON)
        [
           {
              "name": "Hewey",
              "age": 3
           },
           {
              "name": "Dewey",
              "age": 4
           }
        ]
        JSON
      end

    end

    context "set to a whitespace String" do

      it "indents the specified number of spaces" do
        r(:indentation => "\t").list_of :authors, @authors do
          r.element :name
          r.element :age
        end
        expect(resulting_json).to eq undent(<<-JSON)
        [
        \t{
        \t\t"name": "Hewey",
        \t\t"age": 3
        \t},
        \t{
        \t\t"name": "Dewey",
        \t\t"age": 4
        \t}
        ]
        JSON
      end

    end

    context "set false" do

      it "does not indent, or wrap" do
        r(:indentation => false).list_of :authors, @authors do
          r.element :name
          r.element :age
        end
        expect(resulting_json).to eq %([{"name":"Hewey","age":3},{"name":"Dewey","age":4}])
      end

    end

  end

  context "with encoder option" do

    class FakeEncoder
      def self.encode(data)
        (data.to_s + "!!!").inspect
      end
    end

    before do
      @authors = [
        OpenStruct.new(:name => "Hewey", :age => 3),
        OpenStruct.new(:name => "Dewey", :age => 4)
      ]
    end

    it "uses the encoder provided" do
      r(:indentation => false, :encoder => FakeEncoder).list_of :authors, @authors do
        r.element :name
        r.element :age
      end

      expect(resulting_json).to eq %([{"name":"Hewey!!!","age":"3!!!"},{"name":"Dewey!!!","age":"4!!!"}])
    end
  end

end
