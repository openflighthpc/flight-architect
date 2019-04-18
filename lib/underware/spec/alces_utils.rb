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

require 'underware/namespaces/alces'
require 'underware/cluster_attr'
require 'recursive_open_struct'

module Underware
  module AlcesUtils
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
        end
      end

      def included(base)
        start(base)
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
        h = hash_object(h)
        namespace.define_singleton_method(:config) { h }
      end

      def answer(namespace, h = {})
        h = hash_object(h)
        namespace.define_singleton_method(:answer) { h }
      end

      def validation_off
        stub_const('Underware::Constants::SKIP_VALIDATION', true)
      end

      def with_blank_config_and_answer(namespace)
        allow(namespace).to receive(:config).and_return(OpenStruct.new)
        allow(namespace).to receive(:answer).and_return(OpenStruct.new)
      end

      def mock_node(name, *genders)
        AlcesUtils.check_and_raise_fakefs_error
        ClusterAttr.update(alces.cluster_identifier) do |attr|
          genders.push AlcesUtils.default_group if genders.empty?
          attr.add_nodes(name, groups: genders)
        end
        alces.instance_variable_set(:@cluster_attr, nil)
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
        alces.groups.find_by_name(name)
      end

      private

      attr_reader :alces, :test

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
