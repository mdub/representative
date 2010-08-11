require "active_support/core_ext/array"
require "representative/base"
require "json"

module Representative
  
  class Json < Base
    
    def initialize(subject = nil, options = {})
      super(subject, options)
      @buffer = ""
      @indent_level = 0
      now_at :beginning_of_buffer
      yield self if block_given?
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

      label(name)
      value(subject_of_element, &block)
      
    end

    def list_of(name, *args, &block)
      list_subject = args.empty? ? name : args.shift
      items = resolve_value(list_subject)
      label(name)
      inside "[", "]" do
        items.each do |item|
          new_item
          value(item, &block)
        end
      end
    end

    def value(subject)
      representing(subject) do
        if block_given?
          inside "{", "}" do
            yield current_subject
          end
        else
          emit(current_subject.to_json)
        end
      end
      now_at :end_of_item
    end
        
    def comment(text)
      new_item
      emit("// #{text}")
      now_at :end_of_comment
    end

    def to_json
      @buffer + "\n"
    end

    private
    
    def emit(s)
      @buffer << s
    end

    def indentation
      ("  " * @indent_level)
    end

    def label(name)
      return false if @indent_level == 0
      new_item
      emit("#{name.to_s.to_json}: ")
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
      emit("\n#{indentation}") unless at? :beginning_of_block
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
