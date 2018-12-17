# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
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

require 'underware/spec/alces_utils'

RSpec.describe Underware::Commands::Plugin::List do
  include Underware::AlcesUtils

  def run_plugin_list
    Underware::Utils.run_command(
      Underware::Commands::Plugin::List
    )
  end

  before :each do
    FileSystem.root_setup do |fs|
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
