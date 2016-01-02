Representative
==============

"Representative" makes it easier to create XML or JSON representations of your Ruby objects.

It works best when you want the output to roughly follow the object structure, but still want complete control of the result.

Generating XML
--------------

Given a Ruby data-structure:

    @books = [
      Book.new(
        :title => "Sailing for old dogs",
        :authors => ["Jim Watson"],
        :published => Publication.new(
          :by => "Credulous Print",
          :year => 1994
        )
      ),
      Book.new(
        :title => "On the horizon",
        :authors => ["Zoe Primpton", "Stan Ford"],
        :published => Publication.new(
          :by => "McGraw-Hill",
          :year => 2005
        )
      ),
      Book.new(
        :title => "The Little Blue Book of VHS Programming",
        :authors => ["Henry Nelson"],
        :rating => "****"
      )
    ]

Representative::Nokogiri can be used to generate XML:

    xml = Representative::Nokogiri.new do |r|

      r.list_of :books, @books do
        r.element :title
        r.list_of :authors
        r.element :published do
          r.element :by
          r.element :year
        end
      end

    end

    puts xml.to_s

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

      r.list_of :books, @books do
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

    [
      {
        "title": "Sailing for old dogs",
        "authors": [
          "Jim Watson"
        ],
        "published": {
          "by": "Credulous Print",
          "year": 1994
        }
      },
      {
        "title": "On the horizon",
        "authors": [
          "Zoe Primpton",
          "Stan Ford"
        ],
        "published": {
          "by": "McGraw-Hill",
          "year": 2005
        }
      },
      {
        "title": "The Little Blue Book of VHS Programming",
        "authors": [
          "Henry Nelson"
        ],
        "published": null
      }
    ]

Installation
------------

Representative is packaged as a Gem.  Install with:

    gem install representative

Ruby on Rails integration
-------------------------

A separate gem, [RepresentativeView](https://github.com/mdub/representative_view), integrates Representative as an ActionPack template format.

Tilt integration
----------------

Representative includes integration with [Tilt](https://github.com/rtomayko/tilt), which can be enabled with:

    require "representative/tilt_integration"

This registers handlers for "`.xml.rep`" and "`.json.rep`" templates.

Copyright
---------

Copyright (c) 2009-2016 Mike Williams. See LICENSE for details.

Similar projects
----------------

If Representative is not your cup of tea, you may prefer:

* [Tokamak](https://github.com/abril/tokamak)
* [Builder](http://rubygems.org/gems/builder)
* [JSONify](https://github.com/bsiggelkow/jsonify)
* [Argonaut](https://github.com/jbr/argonaut)
* [JSON Builder](https://github.com/dewski/json_builder)
* [RABL](https://github.com/nesquena/rabl)

Just don't go back to using "`this_thing.to_xml`" and "`that_thing.to_json`", m'kay?
