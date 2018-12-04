
# frozen_string_literal: true

require 'hashie'
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
Underware::Utils::DynamicRequire.relative('.')

module Underware
  module Namespaces
    class Alces
      NODE_ERROR = 'Error, a Node is not in scope'
      GROUP_ERROR = 'Error, a Group is not in scope'
      DOUBLE_SCOPE_ERROR = 'A node and group can not both be in scope'
      LOCAL_ERROR = <<-EOF.strip_heredoc
        The local node has not been configured Please run: `underware
        configure local`
      EOF

      delegate :config, :answer, to: :scope
      attr_reader :platform

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

      def initialize(platform: nil)
        @platform = platform&.to_sym
        @stacks_hash = {}
      end

      def alces
        self
      end

      def domain
        @domain ||= Namespaces::Domain.new(alces)
      end

      def nodes
        @nodes ||= begin
          arr = NodeattrInterface.all_nodes.map do |node_name|
            Namespaces::Node.new(alces, node_name)
          end
          Namespaces::UnderwareArray.new(arr)
        end
      end

      def groups
        @groups ||= begin
          arr = group_cache.map do |group_name|
            index = group_cache.index(group_name)
            Namespaces::Group.new(alces, group_name, index: index)
          end
          Namespaces::UnderwareArray.new(arr)
        end
      end

      def data
        DataFileNamespace.new
      end

      def local
        @local ||= begin
          unless nodes.respond_to?(:local)
            raise UninitializedLocalNode, LOCAL_ERROR
          end
          nodes.local
        end
      end

      def build_interface
        @build_interface ||= determine_build_interface
      end

      def orphan_list
        @orphan_list ||= group_cache.orphans
      end

      def questions
        @questions ||= loader.question_tree
      end

      def assets
        @assets ||= AssetArray.new(self)
      end

      def asset_cache
        @asset_cache ||= Underware::Cache::Asset.new
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
          OpenStruct.new(config: HashMergers::Config.new,
                         answer: HashMergers::Answer.new(alces))
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
        Constants::HASH_MERGER_DATA_STRUCTURE.new(namespace) do |template|
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

      def group_cache
        @group_cache ||= GroupCache.new
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
          Network.interfaces.first
        end
      end

      class DataFileNamespace
        delegate :namespace_data_file, to: FilePath

        def method_missing(message, *_args)
          data_file_path = namespace_data_file(message)
          if respond_to?(message)
            Hashie::Mash.load(data_file_path)
          else
            # Normally `method_missing` should call `super` if it doesn't
            # `respond_to?` a message. In this case this is a namespace
            # designed to be used by users writing templates, so give them an
            # informative error message for what they've probably missed
            # instead. This does mean though that we could get a confusing
            # error message if something else goes wrong in this class, so I
            # could eventually come to regret this.
            raise UserUnderwareError,
                  "Requested data file doesn't exist: #{data_file_path}"
          end
        end

        def respond_to_missing?(message, _include_all = false)
          data_file_path = namespace_data_file(message)
          File.exist?(data_file_path)
        end
      end
    end
  end
end
