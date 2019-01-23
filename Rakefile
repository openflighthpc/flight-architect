# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Underware.
#
# Alces Underware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Underware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Underware, please visit:
# https://github.com/alces-software/underware
#==============================================================================

require 'rake'
require 'rspec/core/rake_task'
require 'pry-byebug'

require 'bundler/setup'

task default: ['spec:unit']

namespace :spec do
  CMD_PATTERN = 'spec/underware/{commands,command_helpers}/**/*_spec.rb'

  desc 'Run all the unit tests'
  RSpec::Core::RakeTask.new(:unit) do |task|
    task.exclude_pattern = CMD_PATTERN
  end

  desc 'Run the commands integration specs'
  RSpec::Core::RakeTask.new(:commands) do |task|
    task.pattern = CMD_PATTERN
  end

  desc 'Run all the specs'
  RSpec::Core::RakeTask.new(:all)

  desc 'Rerun previously failed specs'
  RSpec::Core::RakeTask.new(:failures) do |task|
    task.rspec_opts = '--only-failures'
  end
end

desc 'Display the test coverage'
task :coverage do
  `xdg-open coverage/index.html`
end

desc 'Open code in the console'
task :pry do
  require File.join(__dir__, 'lib/underware/cli.rb')
  Pry::REPL.start({})
end

