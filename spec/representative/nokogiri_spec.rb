require 'spec_helper'

require "nokogiri"
require "representative/nokogiri"
require "representative/xml_behaviour"

describe Representative::Nokogiri do

  def r
    @representative ||= Representative::Nokogiri.new(@subject)
  end

  def resulting_xml
    r.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).rstrip
  end

  it_should_behave_like "an XML Representative"
  
end
