# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "geohash_int/version"

Gem::Specification.new do |spec|
  spec.name          = "geohash_int"
  spec.version       = GeohashInt::VERSION
  spec.authors       = ["Ary Borenszweig"]
  spec.email         = ["asterite@gmail.com"]

  spec.summary       = "Fast Geohash for Ruby that yields integers instead of strings"
  spec.description   = "Wraps geohash-int (https://github.com/yinqiwen/geohash-int, " \
                       "a fast C99 geohash library which only provides int64 as hash " \
                       "result) for Ruby using ffi"
  spec.homepage      = "https://github.com/asterite/geohash_int"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    = ['ext/geohash_int/Rakefile']

  spec.add_dependency "ffi", "~> 1.9.18"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
