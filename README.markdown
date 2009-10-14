Representative
==============

"Representative" makes it easier to create XML representations of your Ruby objects.
It works best when you want the XML to roughly follow the object structure, 
but still have complete control of the result.

Example
-------

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

Representative::Xml can be used to generate XML, in a declarative style:

    xml = Builder::XmlMarkup.new(:indent => 2)
    representative = Representative::Xml.new(xml)

    representative.list_of!(:books, books) do |_book|
      _book.title
      _book.list_of!(:authors)
      _book.published do |_published|
        _published.by
        _published.year
      end
    end

    puts xml.target!

The resulting XML looks like this:

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

- Representative generates elements for each object-attribute you name (and not the ones you don't).
- The structure of the XML mirrors the structure described by the nested Ruby blocks.
- Using `list_of!` for a collection attribute generates an "array" element, which plays nicely
  with most Ruby XML-to-hash converters.
- Where a named object-attribute is nil, you get an empty element.

Copyright
---------

Copyright (c) 2009 Mike Williams. See LICENSE for details.
