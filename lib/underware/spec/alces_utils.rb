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

require 'underware/namespaces/alces'
require 'underware/cluster_attr'
require 'recursive_open_struct'

module Underware
  module AlcesUtils
    GENDERS_FILE_REGEX = /-f [[:graph:]]+/
    # Causes the testing version of alces (/config) to be used by underware
    class << self
      def start(example_group)
        example_group.instance_exec do
          # Cache the first version of alces to be created
          # This allows it to be mocked during the spec
          # It can also be reset in the test (see below)
          before do
            allow(Underware::Namespaces::Alces).to \
              receive(:new).and_wrap_original do |m, *a|
                @spec_alces ||= m.call(*a)
              end
          end

          # `alces` is defined as a method so it can be reset
          define_method(:alces) { Underware::Namespaces::Alces.new }
          define_method(:reset_alces) do
            @spec_alces = nil
            alces
          end

          before { AlcesUtils.spoof_nodeattr(self) }
        end
      end

      def included(base)
        start(base)
      end

      def nodeattr_genders_file_path(command)
        return Underware::FilePath.genders unless command.include?('-f')
        command.match(AlcesUtils::GENDERS_FILE_REGEX)[0].sub('-f ', '')
      end

      def nodeattr_cmd_trim_f(command)
        command.sub(AlcesUtils::GENDERS_FILE_REGEX, '')
      end

      # Mocks nodeattr to use faked genders file
      def spoof_nodeattr(context)
        context.instance_exec do
          genders_path = Underware::FilePath.genders
          genders_exist = File.exist? genders_path
          File.write(genders_path, "local local\n") unless genders_exist

          allow(Underware::NodeattrInterface)
            .to receive(:nodeattr).and_wrap_original do |method, *args|
            AlcesUtils.check_and_raise_fakefs_error
            path = AlcesUtils.nodeattr_genders_file_path(args[0])
            cmd = AlcesUtils.nodeattr_cmd_trim_f(args[0])
            genders_data = File.read(path).tr('`', '"')
            tempfile = `mktemp /tmp/genders.XXXXX`.chomp
            begin
              `echo "#{genders_data}" > #{tempfile}`
              nodeattr_cmd = "nodeattr -f #{tempfile}"
              method.call(cmd, mock_nodeattr: nodeattr_cmd)
            ensure
              `rm #{tempfile} -f`
            end
          end
        end
      end

      def redirect_std(*input, &_b)
        old = {
          stdout: $stdout,
          stderr: $stderr,
        }
        buffers = input.map { |k| [k, StringIO.new] }.to_h
        update_std_files buffers
        yield
        buffers.each_value(&:rewind)
        buffers
      ensure
        update_std_files old
      end

      def update_std_files(**hash)
        $stdout = hash[:stdout] if hash[:stdout]
        $stderr = hash[:stderr] if hash[:stderr]
      end

      def mock(test, *a, &b)
        mock_block = lambda do |*_inputs|
          mock_alces = AlcesUtils::Mock.new(self)
          mock_alces.instance_exec(&b)
        end

        if a.empty?
          test.instance_exec(&mock_block)
        else
          test.before(*a, &mock_block)
        end
      end

      def check_and_raise_fakefs_error
        msg = 'Can not use AlcesUtils without FakeFS'
        raise msg unless FakeFS.activated?
      end

      def default_group
        'default-test-group'
      end
    end

    # The following methods have to be initialized with a individual test
    # Example, when using: 'before { AlcesUtils::Mock.new(self) }'
    class Mock
      def initialize(individual_spec_test)
        @test = individual_spec_test
        @alces = test.instance_exec { alces }
      end

      # Used to test basic templating features, avoid use if possible
      def define_method_testing(&block)
        alces.send(:define_singleton_method, :testing, &block)
      end

      def config(namespace, h = {})
        allow(namespace).to receive(:config).and_return(hash_object(h))
      end

      def answer(namespace, h = {})
        allow(namespace).to receive(:answer).and_return(hash_object(h))
      end

      def validation_off
        stub_const('Underware::Constants::SKIP_VALIDATION', true)
      end

      def with_blank_config_and_answer(namespace)
        allow(namespace).to receive(:config).and_return(OpenStruct.new)
        allow(namespace).to receive(:answer).and_return(OpenStruct.new)
      end

      # TODO: Get the new node by reloading the genders file
      def mock_node(name, *genders)
        AlcesUtils.check_and_raise_fakefs_error
        ClusterAttr.update(alces.cluster_identifier) do |attr|
          genders.push AlcesUtils.default_group if genders.empty?
          attr.add_nodes(name, groups: genders)
        end
        alces.instance_variable_set(:@cluster_attr, nil)
        add_node_to_genders_file(name, *genders)
        Underware::Namespaces::Node.new(alces, name).tap do |node|
          new_nodes = alces.nodes.reduce([node], &:push)
          underware_nodes = Underware::Namespaces::UnderwareArray.new(new_nodes)
          allow(alces).to receive(:nodes).and_return(underware_nodes)
        end
      end

      def mock_group(name)
        AlcesUtils.check_and_raise_fakefs_error
        ClusterAttr.update(alces.cluster_identifier) { |a| a.add_group(name) }
        alces.instance_variable_set(:@groups, nil)
        alces.instance_variable_set(:@cluster_attr, nil)
        group = alces.groups.find_by_name(name)
        group
      end

      def create_asset(asset_name, data, type: 'server')
        path = Underware::FilePath.asset(type.pluralize, asset_name)
        FileUtils.mkdir_p(File.dirname(path))
        Underware::Data.dump(path, data)
        alces.instance_variable_set(:@asset_cache, nil)
        alces.instance_variable_set(:@assets, nil)
      end

      def create_layout(layout_name, data, type: 'rack')
        path = Underware::FilePath.layout(type.pluralize, layout_name)
        FileUtils.mkdir_p(File.dirname(path))
        Underware::Data.dump(path, data)
      end

      private

      attr_reader :alces, :test

      def add_node_to_genders_file(name, *genders)
        genders = [AlcesUtils.default_group] if genders.empty?
        genders_entry = "#{name} #{genders.join(',')}\n"
        File.write(Underware::FilePath.genders, genders_entry, mode: 'a')
      end

      # Allows the RSpec methods to be accessed
      def respond_to_missing?(s, *_a)
        test.respond_to?(s)
      end

      def method_missing(s, *a, &b)
        respond_to_missing?(s) ? test.send(s, *a, &b) : super
      end

      def hash_object(h = {})
        Underware::HashMergers::UnderwareRecursiveOpenStruct.new(
          h, eager_render: alces.eager_render
        ) { |str| str }
      end
    end
  end
end
