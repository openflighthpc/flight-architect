
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

require 'ostruct'

require 'underware/exceptions'
require 'underware/templating/renderer'
require 'underware/templating/nil_detection_wrapper'
require 'underware/utils/dynamic_require'
require 'underware/deployment_server'
Underware::Utils::DynamicRequire.relative('mixins')
require 'underware/namespaces/underware_array'
require 'underware/namespaces/hash_merger_namespace'
require 'underware/namespaces/node'
require 'underware/hash_mergers.rb'
require 'underware/underware_log'
require 'underware/cluster_attr'
Underware::Utils::DynamicRequire.relative('.')

module Underware
  module Namespaces
    class Alces
      NODE_ERROR = 'Error, a Node is not in scope'
      GROUP_ERROR = 'Error, a Group is not in scope'
      DOUBLE_SCOPE_ERROR = 'A node and group can not both be in scope'

      delegate :config, :answer, to: :scope
      attr_reader :platform, :eager_render, :cluster_identifier
      alias_method :alces, :itself

      class << self
        LOG_MESSAGE = <<-EOF.strip_heredoc
          Create new Alces namespace. Building multiple namespaces will slow
          down underware as they do not share a file cache. Only build a new
          namespace when required.
        EOF

        def new(*a)
          alces_new_log.info LOG_MESSAGE
          alces_new_log.info caller
          super
        end

        def alces_new_log
          @alces_new_log ||= UnderwareLog.new('alces-new')
        end
      end

      def initialize(platform: nil, eager_render: false)
        @platform = platform&.to_sym
        @eager_render = eager_render
        @stacks_hash = {}
        @cluster_identifier = CommandConfig.load.current_cluster
      end

      def domain
        @domain ||= Namespaces::Domain.new(alces)
      end

      def nodes
        @nodes ||= begin
          arr = cluster_attr.nodes_list.map do |node_name|
            Namespaces::Node.new(alces, node_name)
          end
          Namespaces::UnderwareArray.new(arr)
        end
      end

      def groups
        @groups ||= begin
          arr = cluster_attr.groups_hash.map do |name, index|
            Namespaces::Group.new(alces, name, index: index)
          end
          Namespaces::UnderwareArray.new(arr)
        end
      end

      def data
        DataFileNamespace.new
      end

      def build_interface
        @build_interface ||= determine_build_interface
      end

      def orphan_list
        @orphan_list ||= cluster_attr.orphans
      end

      def questions
        @questions ||= loader.question_tree
      end

      def cluster_attr
        @cluster_attr ||= ClusterAttr.load(cluster_identifier)
      end

      def node
        raise ScopeError, NODE_ERROR unless scope.is_a? Namespaces::Node
        scope
      end

      def group
        raise ScopeError, GROUP_ERROR unless scope.is_a? Namespaces::Group
        scope
      end

      def scope
        dynamic = current_dynamic_namespace || OpenStruct.new
        raise ScopeError, DOUBLE_SCOPE_ERROR if dynamic.group && dynamic.node
        dynamic.node || dynamic.group || domain
      end

      def render_string(template_string, **dynamic_namespace)
        run_with_dynamic(dynamic_namespace) do
          Templating::Renderer
            .replace_erb_with_binding(template_string, wrapped_binding)
        end
      end

      def render_file(template_path, **dynamic_namespace)
        template = File.read(template_path)
        render_string(template, dynamic_namespace)
      rescue StandardError => e
        msg = "Failed to render template: #{template_path}"
        raise e, "#{msg}\n#{e}", e.backtrace
      end

      ##
      # shared hash_merger object which contains a file cache
      #
      def hash_mergers
        @hash_mergers ||= begin
          OpenStruct.new(config: HashMergers::Config.new(eager_render: eager_render),
                         answer: HashMergers::Answer.new(alces, eager_render: eager_render))
        end
      end

      ##
      # method_missing is used to access the dynamic namespace
      #
      def method_missing(s, *_a, &_b)
        respond_to_missing?(s) ? current_dynamic_namespace[s] : super
      end

      def respond_to_missing?(s, *_a)
        current_dynamic_namespace&.key?(s)
      end

      private

      attr_reader :stacks_hash

      def run_with_dynamic(namespace)
        if dynamic_stack.length > Constants::MAXIMUM_RECURSIVE_CONFIG_DEPTH
          raise RecursiveConfigDepthExceededError
        end
        dynamic_stack.push(dynamic_hash(namespace))
        result = yield
        dynamic_stack.pop
        parse_result(result)
      end

      def dynamic_hash(namespace)
        HashMergers::UnderwareRecursiveOpenStruct.new(
          namespace, eager_render: eager_render
        ) do |template|
          alces.render_string(template)
        end
      end

      def parse_result(result)
        case result.strip
        when 'true'
          true
        when 'false'
          false
        when 'nil'
          nil
        when /\A\d+\Z/
          result.to_i
        else
          result
        end
      end

      def current_dynamic_namespace
        dynamic_stack.last
      end

      def dynamic_stack
        stacks_hash[Thread.current] = [] unless stacks_hash[Thread.current]
        stacks_hash[Thread.current]
      end

      def wrapped_binding
        Templating::NilDetectionWrapper.wrap(self)
      end

      def loader
        @loader ||= Validation::Loader.new
      end

      def determine_build_interface
        if config.configured_build_interface&.present?
          config.configured_build_interface
        else
          # Default to first network interface if `build_interface` has not
          # been configured by user.
          Network.available_interfaces.first
        end
      end
    end
  end
end
