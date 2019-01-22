
REMOTE_DIR='/tmp/underware'

# Start Pry console, loading main CLI entry point (so all CLI files should be
# loaded) and all files in `spec` dir.
.PHONY: console
console:
	bundle exec pry --exec 'require_relative "lib/underware/cli"; require "rspec"; $$LOAD_PATH.unshift "spec"; Dir["#{File.dirname(__FILE__)}/spec/**/*.rb"].map { |f| require(f) }; nil'
