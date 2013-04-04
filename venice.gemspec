# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "venice"

Gem::Specification.new do |s|
  s.name        = "venice"
  s.authors     = ["Mattt Thompson"]
  s.email       = "m@mattt.me"
  s.homepage    = "http://github.com/mattt/venice"
  s.version     = Venice::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "iTunes In-App Purchase Receipt Verification"
  s.description = ""

  s.add_dependency "excon", "~> 0.20.0"
  s.add_dependency "json", "~> 1.7.3"
  s.add_dependency "commander", "~> 4.1.2"
  s.add_dependency "terminal-table", "~> 1.4.5"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "simplecov"

  s.files         = Dir["./**/*"].reject { |file| file =~ /\.\/(bin|log|pkg|script|spec|test|vendor)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
