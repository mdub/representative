require "builder"
require "active_support"

module Representative

  class Xml < BlankSlate

    def initialize(xml_builder, subject = nil)
      @xml = xml_builder
      @subject = subject
      yield self if block_given?
    end

    def method_missing(name, *args, &block)
      if name.to_s =~ /!$/
        super
      else
        attribute!(name, *args, &block)
      end
    end

    def attribute!(attribute_name, *args, &block)
      options = args.extract_options!
      value_generator = args.empty? ? attribute_name : args.shift
      raise ArgumentError, "too many arguments" unless args.empty?
      value = resolve(value_generator)
      tag_name = attribute_name.to_s.dasherize
      element!(tag_name, value, resolve_options(options, value), &block)
    end

    def element!(element_name, value, options, &block)
      text = content_generator = nil
      if block && value
        content_generator = Proc.new do
          block.call(Representative::Xml.new(@xml, value))
        end
      else
        text = value
      end
      tag_args = [text, options].compact
      @xml.tag!(element_name, *tag_args, &content_generator)
    end

    def list_of!(attribute_name, *args, &block)
      options = args.extract_options!
      list_tag_name = attribute_name.to_s.dasherize
      list_attributes = options[:list_attributes] || {}
      item_tag_name = options[:item_name] || list_tag_name.singularize
      value_generator = args.empty? ? attribute_name : args.shift
      items = resolve(value_generator)
      list_tag_options = resolve_options(list_attributes, items).merge(:type => "array")
      @xml.tag!(list_tag_name, list_tag_options) do
        items.each do |item|
          element!(item_tag_name, item, {}, &block)
        end
      end
    end

    private 

    def resolve(value_generator, subject = @subject)
      if value_generator.respond_to?(:to_proc)
        value_generator.to_proc.call(subject) if subject
      else
        value_generator
      end
    end

    def resolve_options(options, subject)
      if options
        options.inject({}) do |resolved, (k,v)|
          resolved_value = resolve(v, subject)
          resolved[k.to_s.dasherize] = resolved_value unless resolved_value.nil?
          resolved
        end
      end
    end

  end

end
