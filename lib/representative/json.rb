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
      indent
      emit %(#{name.to_s.to_json}: #{value.to_s.to_json}\n)
    end

    def to_json
      @buffer + "}\n"
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
      emit "{\n"
      increase_indent
    end

    def end_object
      decrease_indent
      emit "}\n"
    end
    
  end
  
  JSON = Json
  
end
