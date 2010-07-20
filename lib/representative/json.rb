require "representative/base"
require "json"

module Representative
  
  class Json < Base
    
    def initialize(subject = nil, options = {})
      super(subject, options)
      @buffer = ""
      @indent_level = 0
      open "{"
      yield self if block_given?
    end
    
    # def element(name, *args, &block)
    def element(name, value)
      emit_label(name)
      emit(value.to_json)
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
      original_buffer = @buffer
      begin
        @buffer = original_buffer.dup
        close "}"
        emit "\n"
        @buffer
      ensure
        @buffer = original_buffer
      end
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
