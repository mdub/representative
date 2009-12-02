require File.dirname(__FILE__) + '/../spec_helper'

require "representative/xml"

require "rexml/document"

describe Representative::Xml do

  before do
    @xml = Builder::XmlMarkup.new
  end

  def represent
    @xml_representative
  end

  def resulting_xml
    @xml.target!
  end

  describe "for some 'subject'" do

    before do
      @subject = OpenStruct.new(:name => "Fred", :width => 200, :vehicle => OpenStruct.new(:year => "1959", :make => "Chevrolet"))
      @xml_representative = Representative::Xml.new(@xml, @subject)
    end

    describe "calling a method" do

      it "generates an element with content extracted from the subject" do
        represent.name
        resulting_xml.should == %(<name>Fred</name>)
      end

      it "dasherizes the method name" do
        @subject.full_name = "Fredrick"
        represent.full_name
        resulting_xml.should == %(<full-name>Fredrick</full-name>)
      end

      describe "with an attribute" do

        it "generates attributes on the element" do
          represent.name(:lang => "fr")
          resulting_xml.should == %(<name lang="fr">Fred</name>)
        end

        it "dasherizes the attribute name" do
          represent.name(:sourced_from => "phonebook")
          resulting_xml.should == %(<name sourced-from="phonebook">Fred</name>)
        end

        describe "whose value supports #to_proc" do

          it "calls the Proc on the subject to generate a value" do
            represent.name(:rev => :reverse)
            resulting_xml.should == %(<name rev="derF">Fred</name>)
          end

        end

        describe "with value nil" do

          it "omits the attribute" do
            represent.name(:lang => nil)
            resulting_xml.should == %(<name>Fred</name>)
          end

        end

      end

      describe "with a non-Hash argument" do

        it "generates an element with explicitly provided content" do
          represent.name("Bloggs")
          resulting_xml.should == %(<name>Bloggs</name>)
        end

        describe "AND a Hash argument" do

          it "generates attributes on the element" do
            represent.name("Bloggs", :lang => "fr")
            resulting_xml.should == %(<name lang="fr">Bloggs</name>)
          end

        end

      end

      describe "with an argument that supports #to_proc" do

        it "calls the Proc on the subject to generate a value" do
          represent.name(:width)
          resulting_xml.should == %(<name>200</name>)
        end

      end

      describe "with argument :self" do

        it "doesn't alter the subject" do
          represent.info(:self) do |info|
            info.name
          end
          resulting_xml.should == %(<info><name>Fred</name></info>)
        end
        
      end

      describe "with a nil argument" do

        it "builds an empty element" do
          represent.name(nil)
          resulting_xml.should == %(<name/>)
        end

        describe "and a Hash entry value that supports #to_proc" do

          it "omits the attribute" do
            represent.name(nil, :size => :size)
            resulting_xml.should == %(<name/>)
          end

        end

        describe "and a block" do

          it "doesn't call the block" do
            represent.name(nil) do |name|
              name.foo
            end
            resulting_xml.should == %(<name/>)
          end

        end

      end

      describe "with a block" do

        it "generates nested elements" do
          represent.vehicle do |vehicle|
            vehicle.year
            vehicle.make
          end
          resulting_xml.should == %(<vehicle><year>1959</year><make>Chevrolet</make></vehicle>)
        end

      end
      
    end

    describe "#empty!" do
      
      it "generates an empty element" do
        represent.empty!(:vehicle, :year => :year)
        resulting_xml.should == %(<vehicle year="1959"/>)
      end

    end
    
    describe "#list_of!" do

      before do
        @subject.nick_names = ["Freddie", "Knucklenose"]
      end

      it "generates an array element" do
        represent.list_of!(:nick_names)
        resulting_xml.should == %(<nick-names type="array"><nick-name>Freddie</nick-name><nick-name>Knucklenose</nick-name></nick-names>)
      end

      describe "with :list_attributes" do
        
        it "attaches attributes to the array element" do
          represent.list_of!(:nick_names, :list_attributes => {:color => "blue", :size => :size})
          array_element_attributes = REXML::Document.new(resulting_xml).root.attributes
          array_element_attributes["type"].should == "array"
          array_element_attributes["color"].should == "blue"
          array_element_attributes["size"].should == "2"
          array_element_attributes.size.should == 3
        end
        
      end

      describe "with :item_attributes" do

        it "attaches attributes to each item element" do
          represent.list_of!(:nick_names, :item_attributes => {:length => :size})
          resulting_xml.should == %(<nick-names type="array"><nick-name length="7">Freddie</nick-name><nick-name length="11">Knucklenose</nick-name></nick-names>)
        end
        
      end

      describe "with an explicit :item_name" do
        it "uses the name provided" do
          represent.list_of!(:nick_names, :item_name => :nick)
          resulting_xml.should == %(<nick-names type="array"><nick>Freddie</nick><nick>Knucklenose</nick></nick-names>)
        end
      end

      describe "with a block" do

        it "generates a nested element for each list element" do
          represent.list_of!(:nick_names) do |nick_name|
            nick_name.length
          end
          resulting_xml.should == %(<nick-names type="array"><nick-name><length>7</length></nick-name><nick-name><length>11</length></nick-name></nick-names>)
        end

      end

      describe "with :item_attributes AND block" do
        
        it "generates attributes and nested elements" do
          represent.list_of!(:nick_names, :item_attributes => {:length => :size}) do |nick_name|
            nick_name.reverse
          end
          resulting_xml.should == %(<nick-names type="array"><nick-name length="7"><reverse>eidderF</reverse></nick-name><nick-name length="11"><reverse>esonelkcunK</reverse></nick-name></nick-names>)
        end
        
      end

    end

  end

end
