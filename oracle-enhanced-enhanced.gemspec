# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "oracle-enhanced-enhanced/version"

Gem::Specification.new do |s|
  s.name        = "oracle-enhanced-enhanced"
  s.version     = Oracle::Enhanced::Enhanced::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve Lamotte"]
  s.email       = ["slamotte@winnipeg.ca"]
  s.homepage    = "http://gems.winnipegtransit.org"
  s.summary     = %q{Additional enhancements/customizations to the excellent ActiveRecord Oracle Enhanced adapter}
  s.description = <<-END
This gem includes several enhancements and customizations to the standard ActiveRecord Oracle Enhanced adapter, which is still required.

Any customizations to this adapter's behaviour or additional Oracle-specific utilities should be added here.
END

  s.rubyforge_project = "oracle-enhanced-enhanced"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activerecord-oracle_enhanced-adapter"
end
