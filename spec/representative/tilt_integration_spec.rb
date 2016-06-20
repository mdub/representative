require 'spec_helper'

require "ostruct"
require "representative/tilt_integration"

describe Representative::Tilt do

  def with_template(file_name, content)
    @template = Tilt.new(file_name, 1) { content }
  end

  def render(*args, &block)
    @output = @template.render(*args, &block)
  end

  describe "XML template" do

    def resulting_xml
      @output.sub(/^<\?xml.*\n/, '')
    end

    describe "#render" do

      it "generates XML" do
        with_template("whatever.xml.rep", <<-RUBY)
          r.element :foo, "bar"
        RUBY
        render
        expect(resulting_xml).to eq %{<foo>bar</foo>\n}
      end

      it "provides access to scope" do

        with_template("whatever.xml.rep", <<-RUBY)
        r.element :author, @mike do
          r.element :name
        end
        RUBY

        scope = Object.new
        scope.instance_eval do
          @mike = OpenStruct.new(:name => "Mike")
        end
        render(scope)

        expect(resulting_xml).to eq undent(<<-XML)
          <author>
            <name>Mike</name>
          </author>
        XML

      end

      it "provides access to local variables" do

        with_template("whatever.xml.rep", <<-RUBY)
        r.element :author, author do
          r.element :name
        end
        RUBY

        render(Object.new, {:author => OpenStruct.new(:name => "Mike")})

        expect(resulting_xml).to eq undent(<<-XML)
          <author>
            <name>Mike</name>
          </author>
        XML

      end

    end

  end

  describe "JSON template" do

    def resulting_json
      @output.sub(/^<\?xml.*\n/, '')
    end

    describe "#render" do

      it "generates JSON" do
        with_template("whatever.json.rep", <<-RUBY)
        r.element :foo, "bar"
        RUBY
        render
        expect(resulting_json).to eq %{"bar"\n}
      end

      it "provides access to scope" do

        with_template("whatever.json.rep", <<-RUBY)
          r.element :author, @mike do
            r.element :name
          end
        RUBY

        scope = Object.new
        scope.instance_eval do
          @mike = OpenStruct.new(:name => "Mike")
        end
        render(scope)

        expect(resulting_json).to eq undent(<<-JSON)
          {
            "name": "Mike"
          }
        JSON

      end

      it "provides access to local variables" do

        with_template("whatever.json.rep", <<-RUBY)
          r.element :author, author do
            r.element :name
          end
        RUBY

        render(Object.new, {:author => OpenStruct.new(:name => "Mike")})

        expect(resulting_json).to eq undent(<<-JSON)
          {
            "name": "Mike"
          }
        JSON

      end

    end

  end

end
