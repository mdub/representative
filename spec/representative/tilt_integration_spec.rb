require 'spec_helper'

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
      
    before do
      with_template("whatever.xml.rep", undent(<<-RUBY))
        r.element :foo, "bar"
      RUBY
    end

    describe "#render" do

      before do
        render
      end
      
      it "generates XML" do
        resulting_xml.should == %{<foo>bar</foo>\n}
      end
      
    end

  end

end
