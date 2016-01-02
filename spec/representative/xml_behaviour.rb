require 'spec_helper'

require "rexml/document"

shared_examples_for "an XML Representative" do

  describe "for some 'subject'" do

    before do
      @subject = OpenStruct.new(
        :name => "Fred",
        :full_name => "Fredrick",
        :width => 200,
        :vehicle => OpenStruct.new(:year => "1959", :make => "Chevrolet")
      )
    end

    describe "#element" do

      it "generates an element with content extracted from the subject" do
        r.element :name
        expect(resulting_xml).to eq %(<name>Fred</name>)
      end

      it "dasherizes the property name" do
        r.element :full_name
        expect(resulting_xml).to eq %(<full-name>Fredrick</full-name>)
      end

      describe "with attributes" do

        it "generates attributes on the element" do
          r.element :name, :lang => "fr"
          expect(resulting_xml).to eq %(<name lang="fr">Fred</name>)
        end

        it "dasherizes the attribute name" do
          r.element :name, :sourced_from => "phonebook"
          expect(resulting_xml).to eq %(<name sourced-from="phonebook">Fred</name>)
        end

        describe "whose value supports #to_proc" do

          it "calls the Proc on the subject to generate a value" do
            r.element :name, :rev => :reverse
            expect(resulting_xml).to eq %(<name rev="derF">Fred</name>)
          end

        end

        describe "with value nil" do

          it "omits the attribute" do
            r.element :name, :lang => nil
            expect(resulting_xml).to eq %(<name>Fred</name>)
          end

        end

      end

      describe "with an explicit value" do

        it "generates an element with explicitly provided content" do
          r.element :name, "Bloggs"
          expect(resulting_xml).to eq %(<name>Bloggs</name>)
        end

        describe "AND attributes" do

          it "generates attributes on the element" do
            r.element :name, "Bloggs", :lang => "fr"
            expect(resulting_xml).to eq %(<name lang="fr">Bloggs</name>)
          end

        end

      end

      describe "with a Symbol value argument" do

        it "calls the named method to generate a value" do
          r.element :name, :width
          expect(resulting_xml).to eq %(<name>200</name>)
        end

      end

      describe "with a value argument that supports #to_proc" do

        it "calls the Proc on the subject to generate a value" do
          r.element :name, (lambda { |x| x.width * 3 })
          expect(resulting_xml).to eq %(<name>600</name>)
        end

      end

      describe "with value argument :self" do

        it "doesn't alter the subject" do
          r.element :info, :self do
            r.element :name
          end
          expect(resulting_xml).to eq %(<info><name>Fred</name></info>)
        end

      end

      describe "with value argument nil" do

        it "builds an empty element" do
          r.element :name, nil
          expect(resulting_xml).to eq %(<name/>)
        end

        describe "and attributes" do

          it "omits attributes derived from the subject" do
            r.element :name, nil, :size => :size
            expect(resulting_xml).to eq %(<name/>)
          end

          it "retains attributes with explicit values" do
            r.element :name, nil, :lang => "en"
            expect(resulting_xml).to eq %(<name lang="en"/>)
          end

        end

        describe "and a block" do

          it "doesn't call the block" do
            r.element :name, nil do
              raise "hell"
            end
            expect(resulting_xml).to eq %(<name/>)
          end

        end

      end

      describe "with a block" do

        it "generates nested elements" do
          r.element :vehicle do
            r.element :year
            r.element :make
          end
          expect(resulting_xml).to eq %(<vehicle><year>1959</year><make>Chevrolet</make></vehicle>)
        end

        it "yields each new subject" do
          r.element :vehicle do |vehicle|
            r.element :year, vehicle.year
          end
          expect(resulting_xml).to eq %(<vehicle><year>1959</year></vehicle>)
        end

      end

      describe "with an EMPTY block" do

        it "generates an empty element" do
          r.element :vehicle, :year => :year, &r.empty
          expect(resulting_xml).to eq %(<vehicle year="1959"/>)
        end

      end

    end

    describe "#list_of" do

      before do
        @subject.nick_names = ["Freddie", "Knucklenose"]
      end

      it "generates an array element" do
        r.list_of(:nick_names)
        expect(resulting_xml).to eq %(<nick-names type="array"><nick-name>Freddie</nick-name><nick-name>Knucklenose</nick-name></nick-names>)
      end

      describe "with a Symbol value argument" do

        it "calls the named method to generate a value" do
          r.list_of(:foo_bars, :nick_names)
          expect(resulting_xml).to eq %(<foo-bars type="array"><foo-bar>Freddie</foo-bar><foo-bar>Knucklenose</foo-bar></foo-bars>)
        end

      end

      it "generates an array element" do
        r.list_of(:nick_names)
        expect(resulting_xml).to eq %(<nick-names type="array"><nick-name>Freddie</nick-name><nick-name>Knucklenose</nick-name></nick-names>)
      end

      describe "with :list_attributes" do

        it "attaches attributes to the array element" do
          r.list_of(:nick_names, :list_attributes => {:color => "blue", :size => :size})
          array_element_attributes = REXML::Document.new(resulting_xml).root.attributes
          expect(array_element_attributes["type"]).to eq "array"
          expect(array_element_attributes["color"]).to eq "blue"
          expect(array_element_attributes["size"]).to eq "2"
          expect(array_element_attributes.size).to eq 3
        end

      end

      describe "with :item_attributes" do

        it "attaches attributes to each item element" do
          r.list_of(:nick_names, :item_attributes => {:length => :size})
          expect(resulting_xml).to eq %(<nick-names type="array"><nick-name length="7">Freddie</nick-name><nick-name length="11">Knucklenose</nick-name></nick-names>)
        end

      end

      describe "with an explicit :item_name" do
        it "uses the name provided" do
          r.list_of(:nick_names, :item_name => :nick)
          expect(resulting_xml).to eq %(<nick-names type="array"><nick>Freddie</nick><nick>Knucklenose</nick></nick-names>)
        end
      end

      describe "with an argument that resolves to nil" do

        it "omits the attribute" do
          r.list_of(:services) do
            r.date
          end
          expect(resulting_xml).to eq %(<services/>)
        end

      end

      describe "with a block" do

        it "generates a nested element for each list element" do
          r.list_of(:nick_names) do
            r.element :length
          end
          expect(resulting_xml).to eq %(<nick-names type="array"><nick-name><length>7</length></nick-name><nick-name><length>11</length></nick-name></nick-names>)
        end

      end

      describe "with an EMPTY block" do

        it "generates empty elements for each list element" do
          r.list_of(:nick_names, :item_attributes => {:value => :to_s}, &r.empty)
          expect(resulting_xml).to eq %(<nick-names type="array"><nick-name value="Freddie"/><nick-name value="Knucklenose"/></nick-names>)
        end

      end

      describe "with :item_attributes AND block" do

        it "generates attributes and nested elements" do
          r.list_of(:nick_names, :item_attributes => {:length => :size}) do
            r.element :reverse
          end
          expect(resulting_xml).to eq %(<nick-names type="array"><nick-name length="7"><reverse>eidderF</reverse></nick-name><nick-name length="11"><reverse>esonelkcunK</reverse></nick-name></nick-names>)
        end

      end

    end

    describe "#representing" do

      it "selects a new subject without generating an element" do
        r.representing :vehicle do
          r.element :make
        end
        expect(resulting_xml).to eq %(<make>Chevrolet</make>)
      end

    end

    describe "#comment" do

      it "inserts a comment" do
        r.element :vehicle do
          r.comment "Year of manufacture"
          r.element :year
        end
        expect(resulting_xml).to eq %(<vehicle><!-- Year of manufacture --><year>1959</year></vehicle>)
      end

    end

    context "with naming_strategy :camelcase" do

      it "generates camelCased element and attribute names" do
        r(:naming_strategy => :camelcase).element :full_name, :foo_bar => 5
        expect(resulting_xml).to eq %(<fullName fooBar="5">Fredrick</fullName>)
      end

    end

    context "with a custom naming_strategy" do

      it "generates suitably transformed names" do
        biff = lambda { |name| name.upcase }
        r(:naming_strategy => biff).element :full_name
        expect(resulting_xml).to eq %(<FULL_NAME>Fredrick</FULL_NAME>)
      end

    end

    context "with no naming_strategy" do

      it "uses raw names" do
        r(:naming_strategy => nil).element :full_name
        expect(resulting_xml).to eq %(<full_name>Fredrick</full_name>)
      end

    end

  end

end
