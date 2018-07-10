# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tracker/version'

Gem::Specification.new do |spec|
  spec.name          = "tracker"
  spec.version       = Tracker::VERSION
  spec.authors       = ["Senthil Arivudainambi"]
  spec.email         = ["senthil@walkerandcobrands.com"]

  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/WalkerAndCoBrandsInc/tracker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "staccato", ">= 0.5"
  spec.add_dependency "activesupport", "~> 4.0.13"
  spec.add_dependency "device_detector"

  spec.add_development_dependency "rack", ">= 1.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "actionpack", "~> 4.0.13"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sidekiq", "~> 2.4.0"
  spec.add_development_dependency "rspec-sidekiq"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "ahoy_matey"
  spec.add_development_dependency "amplitude-api"
end
