require "active_support/core_ext/array"
require "active_support/core_ext/string"
require "builder"
require "representative/empty"
require "representative/object_inspector"

module Representative

  # Easily generate XML while traversing an object-graph.
  #
  class Xml

    # Create an XML-generating Representative.  The first argument should be an instance of
    # Builder::XmlMarkup (or something that implements it's interface).  The second argument
    # if any, is the initial #subject of representation.
    #
    def initialize(xml_builder, subject = nil, options = {})
      @xml = xml_builder
      @subjects = [subject]
      @inspector = options[:inspector] || ObjectInspector.new
      yield self if block_given?
    end

    # Return the current "subject" of representation.  
    #
    # This object will provide element values where they haven't been 
    # explicitly provided.
    #
    def subject
      @subjects.last
    end

    # Evaluate a block with a specified object as #subject.
    #
    def representing(subject)
      @subjects.push(subject)
      begin
        yield subject
      ensure
        @subjects.pop
      end
    end

    # Generate an element.
    #
    # With two arguments, it generates an element with the specified text content.
    # 
    #   r.element :size, 42
    #   # => <size>42</size>
    #
    # More commonly, though, the second argument is omitted, in which case the 
    # element content is assumed to be the named property of the current #subject.
    #
    #   r.representing my_shoe do
    #     r.element :size
    #   end
    #   # => <size>9</size>
    #
    # If a block is attached, nested elements can be generated.  The element "value"
    # (whether explicitly provided, or derived from the current subject) becomes the
    # subject during evaluation of the block.
    #
    #   r.element :book, book do
    #     r.title
    #     r.author
    #   end
    #   # => <book><title>Whatever</title><author>Whoever</author></book>
    #
    # Providing a final Hash argument specifies element attributes.
    #
    #   r.element :size, :type => "integer"
    #   # => <size type="integer">9</size>
    #
    def element(name, *args, &block)

      attributes = args.extract_options!
      attributes = attributes.merge(@inspector.get_metadata(subject, name))

      value_generator = if args.empty? 
        lambda do |subject|
          @inspector.get_value(subject, name)
        end
      else 
        args.shift
      end

      raise ArgumentError, "too many arguments" unless args.empty?

      value = resolve_value(value_generator)
      return @xml.tag!(name) if value.nil?
      
      representing(value) do
        
        content_string = subject.to_s unless block
        content_block = unless block.nil? || block == Representative::EMPTY
          Proc.new do
            block.call(subject)
          end
        end

        resolved_attributes = resolve_attributes(attributes)
        tag_args = [content_string, resolved_attributes].compact

        @xml.tag!(name.to_s.dasherize, *tag_args, &content_block)

      end

    end

    # Generate a list of elements from Enumerable data.
    #
    #   r.list_of :books, my_books do
    #     r.element :title
    #   end
    #   # => <books type="array">
    #   #      <book><title>Sailing for old dogs</title></book>
    #   #      <book><title>On the horizon</title></book>
    #   #      <book><title>The Little Blue Book of VHS Programming</title></book>
    #   #    </books>
    #
    # Like #element, the value can be explicit, but is more commonly extracted
    # by name from the current #subject.
    #
    def list_of(name, *args, &block)

      options = args.extract_options!
      value_generator = args.empty? ? name : args.shift
      raise ArgumentError, "too many arguments" unless args.empty?

      list_attributes = options[:list_attributes] || {}
      item_name = options[:item_name] || name.to_s.singularize
      item_attributes = options[:item_attributes] || {}

      items = resolve_value(value_generator)
      element(name, items, list_attributes.merge(:type => "array")) do
        items.each do |item|
          element(item_name, item, item_attributes, &block)
        end
      end

    end

    # Return a magic value that, when passed to #element as a block, forces
    # generation of an empty element.
    #
    #   r.element(:link, :rel => "me", :href => "http://dogbiscuit.org", &r.empty)
    #   # => <link rel="parent" href="http://dogbiscuit.org"/>
    #
    def empty
      Representative::EMPTY
    end
    
    private 

    def resolve_value(value_generator, subject = subject)
      if value_generator == :self
        subject
      elsif value_generator.respond_to?(:to_proc)
        value_generator.to_proc.call(subject) if subject
      else
        value_generator
      end
    end

    def resolve_attributes(attributes)
      if attributes
        attributes.inject({}) do |resolved, (name, value_generator)|
          resolved_value = resolve_value(value_generator, subject)
          resolved[name.to_s.dasherize] = resolved_value unless resolved_value.nil?
          resolved
        end
      end
    end
    
  end

end
