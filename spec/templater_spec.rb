#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Metalware.
#
# Alces Metalware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Metalware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Metalware, please visit:
# https://github.com/alces-software/metalware
#==============================================================================

require 'active_support/core_ext/string/strip'

require 'templater'
require 'spec_utils'

TEST_TEMPLATE_PATH = File.join(FIXTURES_PATH, 'template.erb')
REPO_TEST_CONFIG_PATH = File.join(FIXTURES_PATH, 'configs/repo-unit-test.yaml')
UNSET_PARAMETER_TEMPLATE_PATH = File.join(FIXTURES_PATH, 'unset_parameter_template.erb')
TEST_HUNTER_PATH = File.join(FIXTURES_PATH, 'cache/hunter.yaml')
EMPTY_REPO_PATH = File.join(FIXTURES_PATH, 'configs/empty-repo.yaml')

RSpec.describe Metalware::Templater do
  def expect_renders(template_parameters, expected, config: Metalware::Config.new)
    # Strip trailing spaces from rendered output to make comparisons less
    # brittle.
    rendered = Metalware::Templater.render(
      config, TEST_TEMPLATE_PATH, template_parameters
    ).gsub(/\s+\n/, "\n")

    expect(rendered).to eq(expected.strip_heredoc)
  end

  # TODO: Their is a lot of override of repos in these tests making it hard to
  # follow which test is using which repo. However once the work with FakeFS is
  # merged into this branch, it should be replace with use the standard location
  # of the repo
  before :each do
    SpecUtils.use_unit_test_config(self)
  end

  describe '#render' do
    context 'without a repo' do
      before :each do
        @config = Metalware::Config.new(EMPTY_REPO_PATH)
      end

      it 'renders template with no extra parameters' do
        expected = <<-EOF
        This is a test template
        some_passed_value:
        some_repo_value:
        erb_repo_value:
        very_recursive_erb_repo_value:
        nested.repo_value:
        alces.index: 0
        EOF

        expect_renders({}, expected, config: @config)
      end

      it 'renders template with extra passed parameters' do
        template_parameters = ({
          some_passed_value: 'my_value'
        })
        expected = <<-EOF
        This is a test template
        some_passed_value: my_value
        some_repo_value:
        erb_repo_value:
        very_recursive_erb_repo_value:
        nested.repo_value:
        alces.index: 0
        EOF

        expect_renders(template_parameters, expected, config: @config)
      end
    end

    context 'with repo' do
      before do
        @config = Metalware::Config.new(REPO_TEST_CONFIG_PATH)
      end

      it 'renders template with repo parameters' do
        expected = <<-EOF
        This is a test template
        some_passed_value:
        some_repo_value: repo_value
        erb_repo_value: 1
        very_recursive_erb_repo_value: repo_value
        nested.repo_value: nested_repo_value
        alces.index: 0
        EOF

        expect_renders({}, expected, config: @config)
      end

      it 'raises if maximum recursive config depth exceeded' do
        stub_const('Metalware::Constants::MAXIMUM_RECURSIVE_CONFIG_DEPTH', 3)

        expect{
          Metalware::Templater.new(@config)
        }.to raise_error(Metalware::RecursiveConfigDepthExceededError)
      end

      it 'raises if attempt to access a property of an unset parameter' do
        expect {
          Metalware::Templater.render(@config, UNSET_PARAMETER_TEMPLATE_PATH, {})
        }.to raise_error Metalware::UnsetParameterAccessError
      end
    end

    context 'when passed node not in genders file' do
      it 'does not raise error' do
        expect {
          Metalware::Templater.render(
            Metalware::Config.new,
            TEST_TEMPLATE_PATH,
            nodename: 'not_in_genders_node01'
          )
        }.to_not raise_error
      end
    end
  end

  describe 'magic alces namespace' do
    def expect_environment_dependent_parameters_present(magic_namespace)
      expect(magic_namespace.hostip).to eq('1.2.3.4')
      expect(magic_namespace.hosts_url).to eq 'http://1.2.3.4/metalware/system/hosts'
      expect(magic_namespace.genders_url).to eq 'http://1.2.3.4/metalware/system/genders'

      # Check hunter config.
      hunter_config = magic_namespace.hunter
      expect(hunter_config.testnode01).to eq('testnode01-mac')
      expect(hunter_config.testnode02).to eq('testnode02-mac')

      # Check genders config.
      genders_config = magic_namespace.genders
      expect(genders_config.masters).to eq(['login1'])
      expect(genders_config.domain).to eq(['login1', 'testnode01', 'testnode02', 'testnode03'])
      expect(genders_config.non_existent).to eq([])
    end

    before do
      # Stub this so mock hunter config used.
      stub_const('Metalware::Constants::HUNTER_PATH', TEST_HUNTER_PATH)

      SpecUtils.use_mock_determine_hostip_script(self)
      SpecUtils.use_mock_genders(self)
    end

    context 'without passed parameters' do
      it 'is created with default values' do
        templater = Metalware::Templater.new(Metalware::Config.new)
        magic_namespace = templater.config.alces

        expect(magic_namespace.index).to eq(0)
        expect(magic_namespace.nodename).to eq(nil)
        expect(magic_namespace.firstboot).to eq(nil)
        expect(magic_namespace.files).to eq(nil)
        expect(magic_namespace.kickstart_url).to eq(nil)
        expect(magic_namespace.build_complete_url).to eq(nil)
        expect_environment_dependent_parameters_present(magic_namespace)
      end
    end

    context 'with passed parameters' do
      it 'overrides defaults with parameter values, where applicable' do
        build_files = SpecUtils.create_mock_build_files_hash(self, 'testnode01')

        templater = Metalware::Templater.new(Metalware::Config.new, {
          nodename: 'testnode01',
          index: 3,
          firstboot: true,
          files: build_files
        })
        magic_namespace = templater.config.alces

        expect(magic_namespace.index).to eq(3)
        expect(magic_namespace.nodename).to eq('testnode01')
        expect(magic_namespace.firstboot).to eq(true)
        expect(magic_namespace.kickstart_url).to eq('http://1.2.3.4/metalware/kickstart/testnode01')
        expect(magic_namespace.build_complete_url).to eq('http://1.2.3.4/metalware/exec/kscomplete.php?name=testnode01')

        # Can reach inside the passed `files` object.
        expect(
          magic_namespace.files.namespace01.first.raw
        ).to eq('/some/other/path')
        expect(
          magic_namespace.files.namespace02.first.raw
        ).to eq('another_file_in_repo')

        expect_environment_dependent_parameters_present(magic_namespace)
      end
    end

    context 'when no hunter config file present' do
      before do
        stub_const('Metalware::Constants::HUNTER_PATH', '/non-existent')
      end

      it 'loads the hunter parameter as an empty array' do
        templater = Metalware::Templater.new(Metalware::Config.new)
        magic_namespace = templater.config.alces
        expect(magic_namespace.hunter).to eq(Hashie::Mash.new)
      end
    end
  end
end
