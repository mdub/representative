require "nokogiri"
require "representative/abstract_xml"
require "representative/empty"

module Representative

  # Easily generate XML while traversing an object-graph.
  #
  class Nokogiri < AbstractXml

    def initialize(subject = nil, options = {})
      super(subject, options)
      @doc = ::Nokogiri::XML::Document.new
      @doc.encoding = 'utf-8'
      @current_element = @doc
      yield self if block_given?
    end

    attr_reader :doc, :current_element

    # Serialize the generated document as XML
    #
    def to_xml(*args)
      doc.to_xml(*args)
    end

    def to_s
      to_xml
    end

    # Generate a comment
    #
    def comment(text)
      comment_node = ::Nokogiri::XML::Comment.new(doc, " #{text} ")
      current_element.add_child(comment_node)
    end

    def attribute(name, value_generator = name)
      attribute_name = name.to_s.dasherize
      value = resolve_value(value_generator)
      unless value.nil?
        current_element[attribute_name] = value.to_s
      end
    end

    private

    def generate_element(name, resolved_attributes, content_string)
      tag_args = [content_string, resolved_attributes].compact
      new_element = doc.create_element(name, *tag_args)
      current_element.add_child(new_element)
      if block_given?
        old_element = @current_element
        begin
          @current_element = new_element
          yield
        ensure
          @current_element = old_element
        end
      end
    end

  end

end