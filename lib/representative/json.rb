require "active_support/core_ext/array"
require "active_support/json"
require "representative/base"

module Representative

  class Json < Base

    DEFAULT_ATTRIBUTE_PREFIX = "@".freeze

    def initialize(subject = nil, options = {})
      super(subject, options)
      @buffer = []
      @indent_level = 0
      @attribute_prefix = options[:attribute_prefix] || DEFAULT_ATTRIBUTE_PREFIX
      now_at :beginning_of_buffer
      yield self if block_given?
    end

    attr_reader :attribute_prefix

    def element(name, *args, &block)

      metadata = @inspector.get_metadata(current_subject, name)
      attributes = args.extract_options!.merge(metadata)

      subject_of_element = if args.empty?
        @inspector.get_value(current_subject, name)
      else
        args.shift
      end

      raise ArgumentError, "too many arguments" unless args.empty?

      label(name)
      value(subject_of_element, attributes, &block)

    end

    def attribute(name, value_generator = name)
      element(attribute_prefix + name.to_s, value_generator)
    end

    def list_of(name, *args, &block)
      options = args.extract_options!
      list_subject = args.empty? ? name : args.shift
      raise ArgumentError, "too many arguments" unless args.empty?
      list_attributes = options[:list_attributes]
      raise ArgumentError, "list_attributes #{list_attributes} not supported for json representation" if list_attributes
      item_attributes = options[:item_attributes] || {}

      items = resolve_value(list_subject)
      label(name)
      inside "[", "]" do
        items.each do |item|
          new_item
          value(item, item_attributes, &block)
        end
      end
    end

    def value(subject, attributes = {})
      representing(subject) do
        if block_given? && !current_subject.nil?
          inside "{", "}" do
            attributes.each do |name, value_generator|
              attribute(name, value_generator)
            end
            yield current_subject
          end
        else
          emit(encode(current_subject))
        end
      end
      now_at :end_of_item
    end

    def comment(text)
      new_item
      emit("// " + text)
      now_at :end_of_comment
    end

    def to_json
      @buffer << "\n"
      @buffer.join
    end

    def to_s
      to_json
    end

    private

    def emit(s)
      @buffer << s
    end

    def encode(data)
      ActiveSupport::JSON.encode(data)
    end

    def indentation
      ("  " * @indent_level)
    end

    def label(name)
      return false if @indent_level == 0
      new_item
      emit(format_name(name).inspect + ": ")
    end

    def new_item
      emit(",") if at? :end_of_item
      emit("\n") unless at? :beginning_of_buffer
      emit(indentation)
      @pending_comma = ","
    end

    def inside(opening_char, closing_char)
      emit(opening_char)
      @indent_level += 1
      now_at :beginning_of_block
      yield
      @indent_level -= 1
      emit("\n" + indentation) unless at? :beginning_of_block
      emit(closing_char)
      now_at :end_of_item
    end

    def now_at(state)
      @state = state
    end

    def at?(state)
      @state == state
    end

  end

  JSON = Json

end
