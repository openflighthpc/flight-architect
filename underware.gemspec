
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "underware/version"

Gem::Specification.new do |spec|
  spec.name          = 'underware'
  spec.version       = Underware::VERSION
  spec.authors       = ['Alces Software Ltd.']
  spec.email         = ['dev@alces-software.com']
  spec.summary       = "Tool/library for managing standard config hierarchy and template rendering under-lying Alces clusters and other Alces tools"
  spec.homepage      = 'https://github.com/alces-software/underware'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Expose everything in `lib` for now; later could lock this down to just what
  # we want to be the Underware Gem's public API.
  spec.files = Dir['lib/**/*']

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '~> 5.1.6'
  spec.add_runtime_dependency 'colorize'
  spec.add_runtime_dependency 'commander'
  spec.add_runtime_dependency 'dry-validation'
  spec.add_runtime_dependency 'hashie'
  spec.add_runtime_dependency 'highline', '1.7.8'
  spec.add_runtime_dependency 'network_interface', '~> 0.0.1'
  spec.add_runtime_dependency 'recursive-open-struct'
  spec.add_runtime_dependency 'ruby-progressbar'
  spec.add_runtime_dependency 'rubytree'
  spec.add_runtime_dependency 'terminal-table'
  spec.add_runtime_dependency 'tty-config'

  # Test dependencies.
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'

  # Development dependencies.
  spec.add_development_dependency "bundler"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rubocop', '~> 0.52.1'
  spec.add_development_dependency 'rubocop-rspec'
end
