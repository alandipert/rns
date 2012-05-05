# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ns/version"

Gem::Specification.new do |s|
  s.name        = "ns"
  s.version     = Ns::VERSION
  s.authors     = ["Alan Dipert"]
  s.email       = ["alan@dipert.org"]
  s.homepage    = "http://github.com/alandipert/ns"
  s.summary     = %q{A library for namespacing pure functions.}
  s.license     = "BSD-new"
  s.description = %q{ns makes it easier to write Ruby programs functionally.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'simplecov'
end
