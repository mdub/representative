require "rubygems"
require "rake"
require "rake/clean"

require "spec/rake/spectask"

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts << "-Du"
  spec.spec_opts << "--color"
end

task :default => :spec

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.rcov = true
end

require "yard"

YARD::Rake::YardocTask.new(:yardoc) do |t|
  t.files   = FileList['lib/**/*.rb']
end

CLEAN << "doc"
