require "representative/object_inspector"

module Representative

  class Base

    def initialize(subject = nil, options = {})
      @subjects = [subject]
      @inspector = options[:inspector] || ObjectInspector.new
      @naming_strategy = options[:naming_strategy] || :plain
    end

    # Return the current "subject" of representation.
    #
    # This object will provide element values where they haven't been
    # explicitly provided.
    #
    def current_subject
      @subjects.last
    end

    alias :subject :current_subject

    # Evaluate a block with a specified object as #subject.
    #
    def representing(new_subject, &block)
      with_subject(resolve_value(new_subject), &block)
    end

    protected

    def with_subject(subject)
      @subjects.push(subject)
      begin
        yield subject
      ensure
        @subjects.pop
      end
    end

    def resolve_value(value_generator)
      if value_generator == :self
        current_subject
      elsif value_generator.kind_of?(Symbol)
        current_subject.send(value_generator) unless current_subject.nil?
      elsif value_generator.respond_to?(:to_proc) && value_generator.to_proc.call(current_subject) != nil
        value_generator.to_proc.call(current_subject) unless current_subject.nil?
      else
        value_generator
      end
    end

    def format_name(name)
      name = name.to_s
      case @naming_strategy
      when :plain
        name
      when :camelcase, :camelCase
        name.camelcase(:lower)
      when Symbol
        name.send(@naming_strategy)
      else
        @naming_strategy.to_proc.call(name)
      end
    end

  end

end
