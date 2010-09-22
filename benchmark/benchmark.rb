$:.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"

require "benchmark"
require "ostruct"

require "representative/json"
require "representative/nokogiri"
require "representative/xml"

@books = [
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

def represent_books_using(r)

  r.list_of :books, @books do
    r.element :title
    r.list_of :authors
    r.element :published do
      r.element :by
      r.element :year
    end
  end

end

def iterations
  1000
end

def bm
  Benchmark.bm(12) do |x|
    x.report("builder") { builder }
    x.report("nokogiri") { nokogiri }
    x.report("json") { json }
  end
end

def builder
  iterations.times do
    xml = Builder::XmlMarkup.new(:indent => 2)
    r = Representative::Xml.new(xml)
    represent_books_using(r)
    xml.target!
  end
end

def nokogiri
  iterations.times do
    xml = Builder::XmlMarkup.new(:indent => 2)
    r = Representative::Nokogiri.new
    represent_books_using(r)
    r.to_xml
  end
end

def json
  iterations.times do
    r = Representative::Json.new
    represent_books_using(r)
    r.to_json
  end
end

action = ARGV.first || "bm"
self.send(action)
