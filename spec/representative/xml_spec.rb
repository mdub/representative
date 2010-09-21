require 'spec_helper'

require "representative/xml"
require "representative/xml_behaviour"
require "rexml/document"

describe Representative::Xml do

  before do
    @xml = Builder::XmlMarkup.new
  end

  def r
    @representative ||= Representative::Xml.new(@xml, @subject)
  end

  def resulting_xml
    @xml.target!
  end

  it_should_behave_like "an XML Representative"
  
end
