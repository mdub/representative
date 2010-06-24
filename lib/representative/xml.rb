require "active_support/core_ext/array"
require "active_support/core_ext/string"
require "builder"
require "representative/empty"
require "representative/object_inspector"

module Representative

  class Xml < BlankSlate

    def initialize(xml_builder, subject = nil, options = {})
      @xml = xml_builder
      @subjects = [subject]
      @inspector = options[:inspector] || ObjectInspector.new
      yield self if block_given?
    end

    def represent(subject, &block)
      @subjects.push(subject)
      begin
        block.call(self)
      ensure
        @subjects.pop
      end
    end
    
    def subject
      @subjects.last
    end
    
    def element(subject_attribute_name, *args, &block)

      element_attributes = args.extract_options!
      value_generator = if args.empty? 
        lambda do |subject|
          @inspector.get_value(subject, subject_attribute_name)
        end
      else 
        args.shift
      end
      raise ArgumentError, "too many arguments" unless args.empty?

      element_name = subject_attribute_name.to_s.dasherize

      value = resolve_value(value_generator)
      resolved_element_attributes = resolve_element_attributes(element_attributes, value)
      resolved_element_attributes.merge!(@inspector.get_metadata(subject, subject_attribute_name))

      element!(element_name, value, resolved_element_attributes, &block)

    end

    def element!(element_name, subject, options, &block)
      content = content_generator = nil
      if block && subject
        unless block == Representative::EMPTY
          content_generator = Proc.new do
            represent(subject, &block)
          end
        end
      else
        content = subject
      end
      tag_args = [content, options].compact
      @xml.tag!(element_name, *tag_args, &content_generator)
    end

    def list_of(attribute_name, *args, &block)

      options = args.extract_options!
      value_generator = args.empty? ? attribute_name : args.shift
      raise ArgumentError, "too many arguments" unless args.empty?

      list_name = attribute_name.to_s.dasherize
      list_element_attributes = options[:list_attributes] || {}
      item_name = options[:item_name] || list_name.singularize
      item_element_attributes = options[:item_attributes] || {}

      items = resolve_value(value_generator)
      if items.nil?
        return @xml.tag!(list_name)
      end

      resolved_list_element_attributes = resolve_element_attributes(list_element_attributes, items)

      @xml.tag!(list_name, resolved_list_element_attributes.merge(:type => "array")) do
        items.each do |item|
          resolved_item_element_attributes = resolve_element_attributes(item_element_attributes, item)
          element!(item_name, item, resolved_item_element_attributes, &block)
        end
      end

    end

    def empty_element(attribute_name, *args)
      element(attribute_name, *args, &Representative::EMPTY)
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

    def resolve_element_attributes(element_attributes, subject)
      if element_attributes
        element_attributes.inject({}) do |resolved, (name, value_generator)|
          resolved_value = resolve_value(value_generator, subject)
          resolved[name.to_s.dasherize] = resolved_value unless resolved_value.nil?
          resolved
        end
      end
    end
    
  end

end
