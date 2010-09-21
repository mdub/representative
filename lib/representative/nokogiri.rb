require "active_support/core_ext"
require "nokogiri"
require "representative/base"
require "representative/empty"

module Representative
  
  class Nokogiri < Base
    
    def initialize(subject = nil, options = {})
      super(subject, options)
      @doc = ::Nokogiri::XML::Document.new
      @current_element = @doc
      yield self if block_given?
    end

    attr_reader :doc, :current_element

    def to_xml(*args)
      doc.to_xml(*args)
    end
    
    def element(name, *args, &block)

      metadata = @inspector.get_metadata(current_subject, name)
      attributes = args.extract_options!.merge(metadata)

      subject_of_element = if args.empty? 
        lambda do |subject|
          @inspector.get_value(current_subject, name)
        end
      else 
        args.shift
      end

      raise ArgumentError, "too many arguments" unless args.empty?

      representing(subject_of_element) do

        content_string = nil

        unless current_subject.nil?
          unless block
            content_string = current_subject.to_s
          end
        end
      
        resolved_attributes = resolve_attributes(attributes)
        tag_args = [content_string, resolved_attributes].compact

        new_element = doc.create_element(name.to_s.dasherize, *tag_args)
        current_element.add_child(new_element)

        if block && block != Representative::EMPTY && !current_subject.nil?
          with_current_element(new_element) do
            block.call(current_subject) 
          end
        end

      end

    end

    def list_of(name, *args, &block)

      options = args.extract_options!
      list_subject = args.empty? ? name : args.shift
      raise ArgumentError, "too many arguments" unless args.empty?

      list_attributes = options[:list_attributes] || {}
      item_name = options[:item_name] || name.to_s.singularize
      item_attributes = options[:item_attributes] || {}

      items = resolve_value(list_subject)
      element(name, items, list_attributes.merge(:type => proc{"array"})) do
        items.each do |item|
          element(item_name, item, item_attributes, &block)
        end
      end

    end

    def empty
      Representative::EMPTY
    end
    
    # Generate a comment
    def comment(text)
      comment_node = ::Nokogiri::XML::Comment.new(doc, " #{text} ")
      current_element.add_child(comment_node)
    end

    private
    
    def with_current_element(element)
      return unless block_given?
      old_element = @current_element
      begin
        @current_element = element
        yield
      ensure
        @current_element = old_element
      end
    end
    
  end
  
end