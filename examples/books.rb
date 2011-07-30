#! /usr/bin/env ruby

require "ostruct"

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

require "representative/json"
require "representative/nokogiri"

def represent_books(r)
  r.list_of :books, @books do
    r.element :title
    r.list_of :authors
    r.element :published do
      r.element :by
      r.element :year
    end
  end
end

puts "\n=== JSON ===\n\n"

Representative::Json.new.tap do |r|
  represent_books(r)
  puts r
end

puts "\n=== XML ===\n\n"

Representative::Nokogiri.new.tap do |r|
  represent_books(r)
  puts r
end
