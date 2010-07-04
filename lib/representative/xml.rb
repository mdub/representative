require "active_support/core_ext/array"
require "active_support/core_ext/string"
require "builder"
require "representative/empty"
require "representative/object_inspector"

module Representative

  class Xml

    def initialize(xml_builder, subject = nil, options = {})
      @xml = xml_builder
      @subjects = [subject]
      @inspector = options[:inspector] || ObjectInspector.new
      yield self if block_given?
    end

    def representing(subject)
      @subjects.push(subject)
      begin
        yield subject
      ensure
        @subjects.pop
      end
    end
    
    def subject
      @subjects.last
    end
    
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
