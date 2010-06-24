require "rubygems"
require "rake"
require "rake/clean"

def with_gem(gem_name, lib = gem_name)
  begin
    require(lib)
  rescue LoadError
    $stderr.puts "WARNING: can't load #{lib}.  Install it with: sudo gem install #{gem_name}"
    return false
  end
  yield
end

require "spec/rake/spectask"

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.rcov = true
end

with_gem "yard" do

  YARD::Rake::YardocTask.new(:yardoc) do |t|
    t.files   = FileList['lib/**/*.rb']
  end
  CLEAN << "doc"

end
