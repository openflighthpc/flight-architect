
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

RSpec.describe Underware::CliHelper::Parser do
  subject do
    described_class.new(
      Underware::Cli.new
    )
  end

  before do
    stub_const('Underware::CliHelper::CONFIG_PATH', test_config_path)
  end

  let(:test_config_path) { '/tmp/config.yaml' }

  describe 'default parsing' do
    def define_config_with_default(default_value)
      File.write(test_config_path, YAML.dump(
                                     'commands' => {
                                       'my_command' => {
                                         'options' => [{
                                           'tags' => ['-f', '--foo'],
                                           'default' => default_value,
                                         }],
                                       },
                                     },
                                     'global_options' => {}
      ))
    end

    it 'passes simple default values straight through as option default' do
      define_config_with_default(5)

      expect_any_instance_of(Commander::Command).to receive(:option).with(
        '-f', '--foo', # tags
        nil, # type
        { default: 5 }, # default
        '' # description
      )

      subject.parse_commands
    end

    it 'uses DynamicDefaults module to determine dynamic default values' do
      define_config_with_default('dynamic' => 'build_interface')

      stubbed_dynamic_default = 'eth3'
      expect(
        Underware::CliHelper::DynamicDefaults
      ).to receive(:build_interface).and_return(stubbed_dynamic_default)

      expect_any_instance_of(Commander::Command).to receive(:option).with(
        '-f', '--foo', # tags
        nil, # type
        { default: stubbed_dynamic_default }, # default
        '' # description
      )

      subject.parse_commands
    end
  end
end
