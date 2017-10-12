# frozen_string_literal: true

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

require 'timeout'

require 'commands/build'
require 'spec_utils'
require 'config'
require 'recursive_open_struct'
require 'network'

# Allows the templates method to be spoofed
module Metalware
  module HashMergers
    class MetalRecursiveOpenStruct
      def templates
        self[:templates]
      end
    end
  end
end

RSpec.shared_examples 'files rendering' do
  #
  # Currently broken. Rspec is having issues due to the mocking of the
  # Templater.render_to_file. Instead the of mocking the render_to_file
  # the FakeFS should be used and then checked after the build is finished
  #
  xit 'renders only files which could be retrieved' do
    filesystem.test do
      # Create needed repo files.
      FileUtils.mkdir_p('/var/lib/metalware/repo/files/testnodes')
      FileUtils.touch('/var/lib/metalware/repo/files/testnodes/some_file_in_repo')

      # Need to define valid build interface so `DeploymentServer` does not
      # fail to get the IP on this interface.
      Metalware::Data.dump(
        Metalware::Constants::SERVER_CONFIG_PATH,
        build_interface: Metalware::Network.interfaces.first
      )

      expect_renders(
        "#{metal_config.repo_path}/files/testnodes/some_file_in_repo",
        to: '/var/lib/metalware/rendered/testnode01/namespace01/some_file_in_repo'
      )

      # Should not try to render any other build files for this node.
      node_rendered_path = '/var/lib/metalware/rendered/testnode01'
      expect(Metalware::Templater).not_to receive(:render_to_file).with(
        anything, /^#{node_rendered_path}/, anything
      )

      run_build('testnode01')
    end
  end
end

RSpec.describe Metalware::Commands::Build do
  let :metal_config { Metalware::Config.new }

  before :each do
    Thread.list.each do |th|
      th.kill unless th == Thread.main
    end
  end

  def run_build(node_identifier, **options_hash)
    # Run command in timeout as `build` will wait indefinitely, but want to
    # abort tests if it looks like this is happening.
    Timeout.timeout 0.5 do
      Metalware::Utils.run_command(
        Metalware::Commands::Build, node_identifier, **options_hash
      )
    end
  end

  # Makes `Node.new` return real `Node`s, but with certain methods stubbed to
  # not depend on environment.
  def use_mock_nodes(not_built_nodes: [])
    allow(
      Metalware::Namespaces::Node
    ).to receive(:new).and_wrap_original do |original_new, *args|
      original_new.call(*args).tap do |node|
        # Stub this as depends on `gethostip` and `/etc/hosts`
        allow(node).to receive(:hexadecimal_ip).and_return(node.name + '_HEX_IP')
      end
    end

    allow_any_instance_of(Metalware::Commands::Build).to \
      receive(:built?).and_wrap_original do |_original, node|
      !not_built_nodes.include?(node.name)
    end
  end

  def expect_runs_longer_than(seconds, &block)
    expect do
      Timeout.timeout(seconds, &block)
    end.to raise_error Timeout::Error
  end

  def expect_renders(template_path, to:)
    expect(Metalware::Templater).to receive(:render_to_file).with(
      instance_of(Metalware::Namespaces::Node),
      template_path,
      to,
      instance_of(Hash)
    )
  end

  let :testnodes_config_path do
    metal_config.repo_config_path('testnodes')
  end

  let :filesystem do
    FileSystem.setup do |fs|
      fs.with_repo_fixtures('repo')
    end
  end

  before :each do
    allow(Metalware::Templater).to receive(:render_to_file)
    use_mock_nodes
    SpecUtils.use_mock_genders(self, genders_file: 'genders/simple_cluster')
    SpecUtils.fake_download_error(self)
    SpecUtils.use_mock_dependency(self)
  end

  context 'when called without group argument' do
    include_examples 'files rendering'

    it 'renders default standard templates for given node' do
      expect_renders(
        "#{metal_config.repo_path}/kickstart/default",
        to: '/var/lib/metalware/rendered/kickstart/testnode01'
      )
      expect_renders(
        "#{metal_config.repo_path}/pxelinux/default",
        to: '/var/lib/tftpboot/pxelinux.cfg/testnode01_HEX_IP'
      ).at_least(:once)

      run_build('testnode01')
    end

    context 'when templates specified in repo config' do
      before :each do
        testnodes_config = OpenStruct.new(
          pxelinux: 'repo_pxelinux',
          kickstart: 'repo_kickstart'
        )

        allow_any_instance_of(
          Metalware::HashMergers::MetalRecursiveOpenStruct
        ).to receive(:templates).and_return(testnodes_config)
      end

      it 'uses specified templates' do
        filesystem.test do
          expect_renders(
            "#{metal_config.repo_path}/kickstart/repo_kickstart",
            to: '/var/lib/metalware/rendered/kickstart/testnode01'
          )
          expect_renders(
            "#{metal_config.repo_path}/pxelinux/repo_pxelinux",
            to: '/var/lib/tftpboot/pxelinux.cfg/testnode01_HEX_IP'
          ).at_least(:once)

          run_build('testnode01')
        end
      end

      #
      # SKIPPED: cluster is not a configured group and thus can not
      # be built
      #
      xit 'specifies correct template dependencies' do
        filesystem.test do
          build_command = run_build('cluster', group: true)

          # Not ideal to test private method, but seems best way in this case.
          dependency_hash = build_command.send(:dependency_hash)

          expect(dependency_hash[:repo].sort).to eq([
            # `default` templates used for node `login1`.
            'pxelinux/default',
            'kickstart/default',

            # Repo templates specified for all nodes in `testnodes` group.
            'pxelinux/repo_pxelinux',
            'kickstart/repo_kickstart',

            # PXELINUX template overridden for `testnode02`
            'pxelinux/testnode02_repo_pxelinux',
          ].sort)
        end
      end
    end

    it 'renders pxelinux once with firstboot true if node does not build' do
      time_to_wait = 0.2
      use_mock_nodes(not_built_nodes: 'testnode01')

      expect_renders(
        "#{metal_config.repo_path}/pxelinux/default",
        to: '/var/lib/tftpboot/pxelinux.cfg/testnode01_HEX_IP'
      ).once

      expect_runs_longer_than(time_to_wait) { run_build('testnode01') }
    end

    it 'renders pxelinux twice with firstboot switched if node builds' do
      expect_renders(
        "#{metal_config.repo_path}/pxelinux/default",
        to: '/var/lib/tftpboot/pxelinux.cfg/testnode01_HEX_IP'
      ).once.ordered
      expect_renders(
        "#{metal_config.repo_path}/pxelinux/default",
        to: '/var/lib/tftpboot/pxelinux.cfg/testnode01_HEX_IP'
      ).once.ordered

      run_build('testnode01')
    end

    context "when 'basic' build method used" do
      before :each do
        allow_any_instance_of(Metalware::Namespaces::Node).to \
          receive(:build_method).and_return(Metalware::BuildMethods::Basic)
      end

      include_examples 'files rendering'

      it 'renders only basic template' do
        filesystem.test do
          # When using the 'basic' build method, the only templates to be
          # rendered for a node are the `files` which can be retrieved, and the
          # `basic` template once at the beginning of the build process.
          allow(Metalware::Templater).to receive(:render_to_file).once
          expect_renders(
            "#{metal_config.repo_path}/basic/default",
            to: '/var/lib/metalware/rendered/basic/testnode01'
          )

          run_build('testnode01')
        end
      end

      # Note: similar (but simpler) version of test for Kickstart build method.
      it 'specifies correct template dependencies' do
        filesystem.test do
          build_command = run_build('testnode01')

          # Not ideal to test private method, but seems best way in this case.
          dependency_hash = build_command.send(:dependency_hash)

          expect(dependency_hash[:repo]).to eq(['basic/default'])
        end
      end
    end
  end

  context 'when called for group' do
    xit 'renders standard templates for each node' do
      expect_renders(
        "#{metal_config.repo_path}/kickstart/default",
        to: '/var/lib/metalware/rendered/kickstart/testnode01'
      )
      expect_renders(
        "#{metal_config.repo_path}/pxelinux/default",
        to: '/var/lib/tftpboot/pxelinux.cfg/testnode01_HEX_IP'
      )

      expect_renders(
        "#{metal_config.repo_path}/kickstart/default",
        to: '/var/lib/metalware/rendered/kickstart/testnode02'
      )
      expect_renders(
        "#{metal_config.repo_path}/pxelinux/default",
        to: '/var/lib/tftpboot/pxelinux.cfg/testnode02_HEX_IP'
      )

      run_build('testnodes', group: true)
    end
  end
end
