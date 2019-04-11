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

require 'underware/spec/alces_utils'

RSpec.describe Underware::Commands::Plugin::List do
  include Underware::AlcesUtils

  def run_plugin_list
    Underware::Utils.run_command(
      Underware::Commands::Plugin::List
    )
  end

  before :each do
    FileSystem.setup do |fs|
      fs.mkdir_p example_plugin_dir_1
      fs.mkdir_p example_plugin_dir_2
      fs.touch junk_other_plugins_dir_file
    end
  end

  let(:example_plugin_dir_1) do
    File.join Underware::FilePath.plugins_dir, 'example01'
  end
  let(:example_plugin_dir_2) do
    File.join Underware::FilePath.plugins_dir, 'example02'
  end
  let(:junk_other_plugins_dir_file) do
    File.join Underware::FilePath.plugins_dir, 'junk'
  end

  it 'outputs line for each plugin subdirectory' do
    stdout = Underware::AlcesUtils.redirect_std(:stdout) do
      run_plugin_list
    end[:stdout].read

    expect(stdout).to match(/example01.*\nexample02.*\n/)
  end

  it 'specifies whether each plugin is activated in output' do
    Underware::Plugins.activate!('example01')
    Underware::Plugins.deactivate!('example02')

    stdout = Underware::AlcesUtils.redirect_std(:stdout) do
      run_plugin_list
    end[:stdout].read

    activated = '[ACTIVATED]'.green
    deactivated = '[DEACTIVATED]'.red
    expect(stdout).to eq "example01 #{activated}\nexample02 #{deactivated}\n"
  end
end
