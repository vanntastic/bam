# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bam/version"

Gem::Specification.new do |s|
  s.name        = "bam"
  s.version     = Bam::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Vann Ek"]
  s.email       = ["vann@innerfusion.net"]
  s.homepage    = "http://rubygems.org/gems/bam"
  s.summary     = %q{A super simple deployment utility}
  s.description = %q{A super simple deployment utility using rsync and git}

  s.rubyforge_project = "bam"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
