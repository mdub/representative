require "active_support/core_ext"
require "builder"
require "representative/abstract_xml"
require "representative/empty"

module Representative

  # Easily generate XML while traversing an object-graph.
  #
  class Xml < AbstractXml

    # Create an XML-generating Representative.  The first argument should be an instance of
    # Builder::XmlMarkup (or something that implements it's interface).  The second argument
    # if any, is the initial #subject of representation.
    #
    def initialize(xml_builder, subject = nil, options = {})
      @xml = xml_builder
      super(subject, options)
      yield self if block_given?
    end

    # Generate a comment
    #
    def comment(text)
      @xml.comment!(text)
    end
    
    protected
    
    def generate_element(name, resolved_attributes, content_string, &content_block)
      tag_args = [content_string, resolved_attributes].compact
      @xml.tag!(name, *tag_args, &content_block)
    end
    
  end

end
