
# frozen_string_literal: true

ruby '2.4.1'
source 'https://rubygems.org'

# Required to fix issue with FakeFS; refer to
# https://github.com/fakefs/fakefs#fakefs-----typeerror-superclass-mismatch-for-class-file.
require 'pp'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# All Underware dependencies are specified in gemspec; some individual Gems
# have different sources specified below as needed (see
# https://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile)
gemspec

gem 'commander', git: 'https://github.com/alces-software/commander'
gem 'pcap', git: 'https://github.com/alces-software/ruby-pcap.git'

# Forked of a fork containing a logger fix. The main gem can be used
# again once StructuredWarnings is removed
gem 'rubytree', git: 'https://github.com/alces-software/RubyTree'
