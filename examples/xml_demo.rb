$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "rubygems"
require "representative/xml"
require "ostruct"

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