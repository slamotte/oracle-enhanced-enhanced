# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "oracle-enhanced-enhanced/version"

Gem::Specification.new do |s|
  s.name        = "oracle-enhanced-enhanced"
  s.version     = Oracle::Enhanced::Enhanced::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve Lamotte"]
  s.email       = ["slamotte@winnipeg.ca"]
  s.homepage    = ""
  s.summary     = %q{Additional enhancements/customizations to the Oracle Enhanced adapter}
  s.description = %q{This gem includes several enhancements and customizationt to the standard Oracle Enhanced adapter, which is still required. Any customizations to this adapter's behaviour or additional Oracle-specific utilities should be added here.}

  s.rubyforge_project = "oracle-enhanced-enhanced"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord-oracle_enhanced-adapter"
end
