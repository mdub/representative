require "active_support/core_ext/array"
require "representative/base"
require "json"

module Representative
  
  class Json < Base
    
    def initialize(subject = nil, options = {})
      super(subject, options)
      @buffer = ""
      @indent_level = 0
      yield self if block_given?
    end
    
    def element(name, *args)

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

        emit_label(name)
        if block_given?
          open "{"
          yield current_subject
          close "}"
        else
          emit(current_subject.to_json)
        end

      end
      
    end

    def list_of(name, values)
      emit_label(name)
      open "["
      values.each do |value|
        optional_comma
        newline_and_indent
        emit(value.to_json)
      end
      close "]"
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

    def increase_indent
      @indent_level += 1
    end

    def decrease_indent
      @indent_level -= 1
    end

    def emit_label(name)
      return false if @indent_level == 0
      optional_comma
      newline_and_indent
      emit("#{name.to_s.to_json}: ")
    end

    def optional_comma
      emit(",") unless @start_of_block
      @start_of_block = false
    end
    
    def newline_and_indent
      emit("\n#{indentation}")
    end
    
    def open(opening_char)
      emit(opening_char)
      increase_indent
      @start_of_block = true
    end

    def close(closing_char)
      decrease_indent
      unless @start_of_block
        newline_and_indent
      end
      emit(closing_char)
    end
    
  end
  
  JSON = Json
  
end
