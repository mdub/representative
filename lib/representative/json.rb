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
      emit(@comma)
      emit "\n"
      indent
      emit %(#{name.to_s.to_json}: #{value.to_json})
      @comma = ","
    end

    def to_json
      @buffer + "\n}\n"
    end

    private
    
    def emit(s)
      @buffer << s
    end

    def indent
      emit ("  " * @indent_level)
    end

    def increase_indent
      @indent_level += 1
    end

    def decrease_indent
      @indent_level -= 1
    end

    def start_object
      emit "{"
      increase_indent
      @comma = ""
    end

    def end_object
      decrease_indent
      emit "\n}\n"
    end
    
  end
  
  JSON = Json
  
end
