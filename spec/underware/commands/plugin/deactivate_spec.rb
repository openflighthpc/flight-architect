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

RSpec.describe Underware::Commands::Plugin::Deactivate do
  include Underware::AlcesUtils

  def run_plugin_deactivate(plugin_name)
    Underware::Utils.run_command(
      Underware::Commands::Plugin::Deactivate, plugin_name
    )
  end

  before :each do
    FileSystem.setup do |fs|
      fs.mkdir_p example_plugin_dir
    end
  end

  let(:example_plugin_dir) do
    File.join Underware::FilePath.plugins_dir, example_plugin_name
  end
  let(:example_plugin_name) { 'example' }

  def example_plugin
    Underware::Plugins.all.find do |plugin|
      plugin.name == example_plugin_name
    end
  end

  it 'switches the plugin to be deactivated' do
    expect(example_plugin).to be_activated

    run_plugin_deactivate(example_plugin_name)

    expect(example_plugin).not_to be_activated
  end

  it 'does not duplicate deactivated plugin if already deactivated' do
    run_plugin_deactivate(example_plugin_name)
    run_plugin_deactivate(example_plugin_name)

    matching_deactivated_plugins = Underware::Plugins.all.select do |plugin|
      !plugin.activated? && plugin.name == example_plugin_name
    end
    expect(matching_deactivated_plugins.length).to eq 1
  end

  it 'gives error if plugin does not exist' do
    unknown_plugin_name = 'unknown_plugin'

    expect do
      Underware::AlcesUtils.redirect_std(:stderr) do
        run_plugin_deactivate(unknown_plugin_name)
      end
    end.to raise_error Underware::UnderwareError,
    "Unknown plugin: #{unknown_plugin_name}"
  end
end
