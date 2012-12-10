# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'popo/version'

Gem::Specification.new do |s|
  s.name        = "popo"
  s.version     = Popo::VERSION
  s.authors     = ["Jan Mendoza"]
  s.email       = ["poymode@gmail.com"]
  s.homepage    = "https://github.com/poymode/popo"
  s.summary     = %q{Popo ruby and rails repo tool}
  s.description = %q{Ruby and rails repo tool}

  s.add_dependency "cableguy"
  s.add_dependency "thor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
