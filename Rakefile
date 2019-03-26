# frozen_string_literal: true

# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Architect.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Architect is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Architect. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Architect, please visit:
# https://github.com/openflighthpc/flight-architect
# ==============================================================================

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
