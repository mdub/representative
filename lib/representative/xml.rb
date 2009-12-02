require "builder"
require "active_support"
require "representative/empty"

module Representative

  class Xml < BlankSlate

    def initialize(xml_builder, subject = nil)
      @xml = xml_builder
      @subjects = [subject]
      yield self if block_given?
    end

    def method_missing(name, *args, &block)
      if name.to_s =~ /!$/
        super
      else
        property!(name, *args, &block)
      end
    end

    def subject!
      @subjects.last
    end
    
    def property!(property_name, *args, &block)

      attributes = args.extract_options!
      value_generator = args.empty? ? property_name : args.shift
      raise ArgumentError, "too many arguments" unless args.empty?

      element_name = property_name.to_s.dasherize

      value = resolve(value_generator)
      resolved_attributes = resolve_attributes(attributes, value)

      element!(element_name, value, resolved_attributes, &block)

    end

    def element!(element_name, subject, options, &block)
      content = content_generator = nil
      if block && subject
        unless block == Representative::EMPTY
          content_generator = Proc.new do
            @subjects.push(subject)
            begin
              block.call(self)
            ensure
              @subjects.pop
            end
          end
        end
      else
        content = subject
      end
      tag_args = [content, options].compact
      @xml.tag!(element_name, *tag_args, &content_generator)
    end

    def list_of!(property_name, *args, &block)

      options = args.extract_options!
      value_generator = args.empty? ? property_name : args.shift
      raise ArgumentError, "too many arguments" unless args.empty?

      list_name = property_name.to_s.dasherize
      list_attributes = options[:list_attributes] || {}
      item_name = options[:item_name] || list_name.singularize
      item_attributes = options[:item_attributes] || {}

      items = resolve(value_generator)
      resolved_list_attributes = resolve_attributes(list_attributes, items)

      @xml.tag!(list_name, resolved_list_attributes.merge(:type => "array")) do
        items.each do |item|
          resolved_item_attributes = resolve_attributes(item_attributes, item)
          element!(item_name, item, resolved_item_attributes, &block)
        end
      end

    end

    private 

    def resolve(value_generator, subject = subject!)
      if value_generator.respond_to?(:to_proc)
        value_generator.to_proc.call(subject) if subject
      else
        value_generator
      end
    end

    def resolve_attributes(attributes, subject)
      if attributes
        attributes.inject({}) do |resolved, (k,v)|
          resolved_value = resolve(v, subject)
          resolved[k.to_s.dasherize] = resolved_value unless resolved_value.nil?
          resolved
        end
      end
    end

  end

end
