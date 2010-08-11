Representative
==============

"Representative" makes it easier to create XML or JSON representations of your Ruby objects.

It works best when you want the output to roughly follow the object structure, but still want complete control of the result.

Generating XML
--------------


Given a Ruby data-structure:

    books = [
      OpenStruct.new(
        :title => "Sailing for old dogs", 
        :authors => ["Jim Watson"],
        :published => OpenStruct.new(
          :by => "Credulous Print",
          :year => 1994
        )
      ),
      OpenStruct.new(
        :title => "On the horizon", 
        :authors => ["Zoe Primpton", "Stan Ford"],
        :published => OpenStruct.new(
          :by => "McGraw-Hill",
          :year => 2005
        )
      ),
      OpenStruct.new(
        :title => "The Little Blue Book of VHS Programming",
        :authors => ["Henry Nelson"],
        :rating => "****"
      )
    ]

Representative::Xml can be used to generate XML:

    xml = Builder::XmlMarkup.new(:indent => 2)

    Representative::Xml.new(xml) do |r|
    
      r.list_of :books, books do
        r.element :title
        r.list_of :authors
        r.element :published do
          r.element :by
          r.element :year
        end
      end
      
    end

    puts xml.target!

which produces:

    <books type="array">
      <book>
        <title>Sailing for old dogs</title>
        <authors type="array">
          <author>Jim Watson</author>
        </authors>
        <published>
          <by>Credulous Print</by>
          <year>1994</year>
        </published>
      </book>
      <book>
        <title>On the horizon</title>
        <authors type="array">
          <author>Zoe Primpton</author>
          <author>Stan Ford</author>
        </authors>
        <published>
          <by>McGraw-Hill</by>
          <year>2005</year>
        </published>
      </book>
      <book>
        <title>The Little Blue Book of VHS Programming</title>
        <authors type="array">
          <author>Henry Nelson</author>
        </authors>
        <published/>
      </book>
    </books>

Notice that:

- The structure of the output mirrors the structure described by the nested Ruby blocks.
- Representative walks the object-graph for you.
- Using `list_of` for a collection attribute generates an "array" element, which plays nicely
  with most Ruby XML-to-hash converters.
- Where a named object-attribute is nil, you get an empty element.

Generating JSON
---------------

Representative::Json can be used to generate JSON, using exactly the same DSL:

    json = Representative::Json.new do |r|
      r.list_of :books, books do
        r.element :title
        r.list_of :authors
        r.element :published do
          r.element :by
          r.element :year
        end
      end
    end

    puts json.to_s

producing:

    ... JSON goes here ...

Installation
------------

Representative is packaged as a Gem.  Install with:

    gem install representative

Copyright
---------

Copyright (c) 2009 Mike Williams. See LICENSE for details.
