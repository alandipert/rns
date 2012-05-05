# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rns/version"

Gem::Specification.new do |s|
  s.name        = "rns"
  s.version     = Rns::VERSION
  s.authors     = ["Alan Dipert"]
  s.email       = ["alan@dipert.org"]
  s.homepage    = "http://github.com/alandipert/rns"
  s.summary     = %q{A library for namespacing pure functions.}
  s.license     = "BSD-new"
  s.description = %q{rns is a namespace management library designed to ease functional programming in Ruby.}

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
