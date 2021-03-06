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

RSpec.shared_examples 'render command' do |args|
  def run_command(*args)
    Underware::AlcesUtils.redirect_std(:stdout) do
      Underware::Utils.run_command(
        described_class, *args
      )
    end[:stdout].read
  end

  let(:template) do
    template_contents = <<~TEMPLATE.strip_heredoc
      Rendered with scope: <%= scope.class %>
      #{'Scope name: <%= scope.name %>' unless described_class == Underware::Commands::Render::Domain}
      Platform config value: <%= config.platform_config_key %>
    TEMPLATE

    Tempfile.create.tap { |t| t.write(template_contents) }
  end

  # Below tests are very similar for all `render` commands, so can live here
  # while remaining clear. Other tests which vary more between commands have
  # been left in their respective files to avoid over-abstracting and confusing
  # things.
  describe 'with `--platform` option passed' do
    let(:platform_config_path) do
      Underware::FilePath.platform_config(:test_platform)
    end

    it 'includes config for given platform when forming namespace' do
      Underware::Data.dump(
        platform_config_path,
        platform_config_key: 'platform_config_value'
      )
      File.read Underware::FilePath.platform_config(:test_platform)

      output = run_command(*command_args, platform: :test_platform)

      expect(output).to include "Platform config value: platform_config_value\n"
    end

    it 'gives error if no config exists for platform' do
      expect do
        run_command(*command_args, platform: :test_platform)
      end.to raise_error(
        Underware::InvalidInput,
        "Unknown platform: test_platform (#{platform_config_path} does not exist)"
      )
    end
  end

  it 'attempts to render relative to working directory, when relative path passed' do
    ENV['OLDPWD'] = '/some/working/dir'
    command_args_with_relative_template = command_args.tap do |args_|
      args_[-1] = 'relative/template'
    end

    # The specific type of namespace which is rendered against will depend on
    # which command we are actually testing, but we can reasonably assume the
    # correct one is rendered against in each case as this is covered by other
    # tests, and just check the correct template path is passed here.
    expect_any_instance_of(Underware::Namespaces::HashMergerNamespace)
      .to receive(:render_file)
      .with('/some/working/dir/relative/template')

    run_command(*command_args_with_relative_template)
  end
end
