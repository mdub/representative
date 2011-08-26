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
    %w(rep_xml rep_nokogiri rep_json use_to_json).each do |method|
      x.report(method) do
        iterations.times do
          send(method)
        end
      end
    end
  end
  nil
end

def rep_xml
  xml = Builder::XmlMarkup.new(:indent => 2)
  r = Representative::Xml.new(xml)
  represent_books_using(r)
  xml.target!
end

def rep_nokogiri
  r = Representative::Nokogiri.new
  represent_books_using(r)
  r.to_xml
end

def rep_json
  r = Representative::Json.new
  represent_books_using(r)
  r.to_json
end

def use_to_json
  book_data = @books.map do |book|
    {
      :title => book.title,
      :authors => book.authors,
      :published => if book.published
        {
          :by => book.published.by,
          :year => book.published.year
        }
      end
    }
  end
  book_data.to_json
end

action = ARGV.first || "bm"
puts self.send(action)
