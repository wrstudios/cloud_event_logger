
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "lib/version"

Gem::Specification.new do |spec|
  spec.name          = "cloud-event-logger"
  spec.version       = CloudEventLogger::VERSION
  spec.authors       = ["“aboehm”"]
  spec.email         = ["boehm.adam@gmail.com"]
  spec.summary       = %q{initiating repo, will add asap Write a short summary, because RubyGems requires one.}
  spec.description   = %q{initiating repo, will add asap Write a longer description or delete this line.}
  spec.homepage      = 'http://github.com/wrstudios/cloud_event_logger'
  spec.license       = "MIT"
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency 'hashie'
end
