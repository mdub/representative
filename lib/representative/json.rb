require "representative/base"
require "json"

module Representative
  
  class Json < Base
    
    def initialize(subject = nil, options = {})
      super(subject, options)
      @buffer = ""
      @indent_level = 0
      start_object
      yield self if block_given?
    end

    # def element(name, *args, &block)
    def element(name, value)
      emit_label(name)
      emit(value.to_json)
    end

    def list_of(name, values)
      emit_label(name)
      start_array
      values.each do |value|
        newline_and_indent
        emit(value.to_json)
      end
      end_array
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
    
    def start_object
      emit "{"
      increase_indent
      @comma = ""
    end

    def end_object
      decrease_indent
      emit "\n#{indentation}}"
    end

    def start_array
      emit "["
      increase_indent
      @comma = ""
    end

    def end_array
      decrease_indent
      emit "\n#{indentation}]"
    end
    
  end
  
  JSON = Json
  
end
