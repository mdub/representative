require "tilt"

module Representative
  module Tilt

    class NokogiriTemplate < ::Tilt::Template

      def initialize_engine
        return if defined?(Representative::Nokogiri)
        require_template_library 'representative/nokogiri'
      end

      def prepare
      end

      def evaluate(scope, locals, &block)
        r = Representative::Nokogiri.new
        locals[:r] = r
        super(scope, locals, &block)
        r.to_xml
      end

      def precompiled_template(locals)
        data.to_str
      end

    end
    
    class JsonTemplate < ::Tilt::Template

      def initialize_engine
        return if defined?(Representative::Json)
        require_template_library 'representative/json'
      end

      def prepare
      end

      def evaluate(scope, locals, &block)
        r = Representative::Json.new
        locals[:r] = r
        super(scope, locals, &block)
        r.to_json
      end

      def precompiled_template(locals)
        data.to_str
      end

    end

  end
end

Tilt.register 'xml.rep', Representative::Tilt::NokogiriTemplate
Tilt.register 'json.rep', Representative::Tilt::JsonTemplate
