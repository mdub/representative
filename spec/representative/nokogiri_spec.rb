require 'spec_helper'

require "nokogiri"
require "representative/nokogiri"
require "representative/xml_behaviour"

describe Representative::Nokogiri do

  def r(options = {})
    @representative ||= Representative::Nokogiri.new(@subject, options)
  end

  def resulting_xml
    r.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).rstrip
  end

  it_should_behave_like "an XML Representative"

  describe "for some 'subject'" do

    before do
      @subject = OpenStruct.new(:name => "Fred", :width => 200, :vehicle => OpenStruct.new(:year => "1959", :make => "Chevrolet"))
    end

    describe "#attribute" do

      describe "without a value argument" do
        it "extracts the named field of the subject" do
          r.element :person, @subject do
            r.attribute :name
          end
          expect(resulting_xml).to eq %(<person name="Fred"/>)
        end
      end

      describe "with an explicit value" do
        it "attaches an attribute to the current element" do
          r.element :person, @subject do
            r.attribute :lang, "fr"
          end
          expect(resulting_xml).to eq %(<person lang="fr"/>)
        end
      end

      describe "with a value that supports #to_proc" do
        it "calls the Proc on the subject to generate attribute value" do
          r.element :person, @subject do
            r.attribute :name, lambda { |person| person.name.reverse }
          end
          expect(resulting_xml).to eq %(<person name="derF"/>)
        end
      end

      it "dasherizes the attribute name" do
        r.element :name do
          r.attribute :sourced_from, "phonebook"
        end
        expect(resulting_xml).to eq %(<name sourced-from="phonebook"/>)
      end

      describe "with value nil" do
        it "omits the attribute" do
          r.element :person, @subject do
            r.attribute :name, nil
          end
          expect(resulting_xml).to eq %(<person/>)
        end
      end

    end

  end

end
