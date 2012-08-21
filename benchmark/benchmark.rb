#! /usr/bin/env ruby

$:.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"

require "clamp"
require "benchmark"
require "ostruct"

require "jbuilder"

require "representative/json"
require "representative/nokogiri"
require "representative/xml"

$books = [
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

class RepresentativeBenchmark < Clamp::Command

  ALL_STRATEGIES = %w(builder nokogiri json to_json jbuilder)

  def self.validate_strategy(strategy)
    unless ALL_STRATEGIES.member?(strategy)
      raise ArgumentError, "invalid strategy: #{strategy}"
    end
    strategy
  end

  subcommand "bm", "Benchmark" do

    option ["-n", "--iterations"], "N", "number of iterations", :default => 1000, &method(:Integer)
    option ["--profile"], :flag, "profile output type"
    option ["--profile-format"], "FORMAT", "'flat' or 'graph'", :default => "flat"

    parameter "[STRATEGY] ...", "representation strategies\n(default: #{ALL_STRATEGIES.join(", ")})", :attribute_name => "strategies" do |strategies|
      strategies.each { |strategy| RepresentativeBenchmark.validate_strategy(strategy) }
    end

    def execute
      self.strategies = ALL_STRATEGIES if strategies.empty?
      with_profiling do
        Benchmark.bm(12) do |x|
          strategies.each do |strategy|
            x.report(strategy) do
              iterations.times do
                send("with_#{strategy}")
              end
            end
          end
        end
      end
    end

  end

  def with_profiling
    if profile?
      require 'ruby-prof'
      result = RubyProf.profile do
        yield
      end
      printer_class = RubyProf.const_get("#{profile_format.capitalize}Printer")
      printer_class.new(result).print(STDOUT)
    else
      yield
    end
  end

  subcommand ["print", "p"], "Show output of a specified strategy" do

    parameter "STRATEGY", "one of: #{ALL_STRATEGIES.join(", ")}" do |strategy|
      RepresentativeBenchmark.validate_strategy(strategy)
    end

    def execute
      puts send("with_#{strategy}")
    end

  end

  private

  def represent_books_using(r)

    r.list_of :books, $books do
      r.element :title
      r.list_of :authors
      r.element :published do
        r.element :by
        r.element :year
      end
    end

  end

  def with_builder
    xml = Builder::XmlMarkup.new(:indent => 2)
    r = Representative::Xml.new(xml)
    represent_books_using(r)
    xml.target!
  end

  def with_nokogiri
    r = Representative::Nokogiri.new
    represent_books_using(r)
    r.to_xml
  end

  def with_json
    r = Representative::Json.new(nil, :indentation => false)
    represent_books_using(r)
    r.to_json
  end

  def with_to_json
    book_data = $books.map do |book|
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

  def with_jbuilder
    Jbuilder.encode do |json|
      json.array!($books) do |json, book|
        json.title(book.title)
        json.authors(book.authors)
        if book.published
          json.published do |json|
            json.by(book.published.by)
            json.year(book.published.year)
          end
        else
          json.published(nil)
        end
      end
    end
  end

end

RepresentativeBenchmark.run
