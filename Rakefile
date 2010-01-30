require 'rubygems'

require 'rake/gempackagetask'

gemspec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "mongodb_adapter"
  s.version = "0.1.3"
  s.author = "Mark Rendle"
  s.date = "2010-01-30"
  s.email = "mark@okify.com"

  s.add_dependency "mongo", ">= 0.18.0"

  s.files = [
    ".document",
     ".gitignore",
     "FIXME",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "mongodb_adapter.gemspec",
     "lib/mongodb_adapter.rb",
     "spec/mongodb_adapter_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/okify/mongodb_adapter"
  s.require_paths = ["lib"]
  s.summary = "MongoDB adapter for DataMapper"
  s.test_files = [
    "spec/mongodb_adapter_spec.rb",
     "spec/spec_helper.rb"
  ]
end

Rake::GemPackageTask.new(gemspec) do |p|
  p.need_tar = false
  p.need_zip = true
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mongodb_adapter #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

