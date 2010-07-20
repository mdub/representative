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
        newline_and_indent
        emit(value.to_json)
      end
      close "]"
    end
    
    def to_json
      @buffer + "\n}\n"
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
      newline_and_indent
      emit("#{name.to_s.to_json}: ")
    end

    def newline_and_indent
      emit("#{@comma}\n#{indentation}")
      @comma = ","
    end
    
    def open(opening_char)
      emit opening_char
      increase_indent
      @comma = ""
    end

    def close(closing_char)
      decrease_indent
      emit "\n#{indentation}#{closing_char}"
    end
    
  end
  
  JSON = Json
  
end
