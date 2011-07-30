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

json = Representative::Json.new.tap { |r| represent_books(r) }.to_s
puts json

puts "\n=== XML ===\n\n"

xml = Representative::Nokogiri.new.tap { |r| represent_books(r) }.to_s
puts xml
