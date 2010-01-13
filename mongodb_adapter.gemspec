# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongodb_adapter}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Rendle"]
  s.date = %q{2010-01-13}
  s.email = %q{mark@okify.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
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
  s.homepage = %q{http://github.com/okify/mongodb_adapter}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{MongoDB adapter for DataMapper}
  s.test_files = [
    "spec/mongodb_adapter_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
