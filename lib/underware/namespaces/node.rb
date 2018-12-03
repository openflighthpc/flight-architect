
# frozen_string_literal: true

require 'underware/namespaces/plugin'

module Underware
  module Namespaces
    class Node < HashMergerNamespace
      include Namespaces::Mixins::Name

      def group
        @group ||= alces.groups.send(genders.first)
      end

      def genders
        @genders ||= NodeattrInterface.genders_for_node(name)
      end

      def index
        @index ||= begin
          group.nodes.each_with_index do |other_node, index|
            return index + 1 if other_node == self
          end
          raise InternalError, 'Node does not appear in its primary group'
        end
      end

      def kickstart_url
        @kickstart_url ||= DeploymentServer.kickstart_url(name)
      end

      def build_complete_path
        @build_complete_path ||= FilePath.build_complete(self)
      end

      def build_complete_url
        @build_complete_url ||= DeploymentServer.build_complete_url(name)
      end

      def genders_url
        @genders_url ||= DeploymentServer.system_file_url('genders')
      end

      def events_dir
        FilePath.event self
      end

      def plugins
        @plugins ||= UnderwareArray.new(enabled_plugin_namespaces)
      end

      def asset
        @asset ||= begin
          asset_name = alces.asset_cache.asset_for_node(self)
          return unless asset_name
          alces.assets.find_by_name(asset_name)
        end
      end

      def local?
        name == 'local'
      end

      private

      def white_list_for_hasher
        super.concat([
                       :group,
                       :genders,
                       :index,
                       :kickstart_url,
                       :build_complete_url,
                       :build_complete_path,
                     ])
      end

      def recursive_array_white_list_for_hasher
        super.push(:plugins)
      end

      def hash_merger_input
        { groups: genders, node: name }
      rescue NodeNotInGendersError
        # The answer hash needs to be accessible by the Configurator. Nodes in
        # a group work fine as they appear in the genders file BUT local and
        # orphan nodes DO NOT appear in the genders file and cause the above
        # error.
        { groups: ['orphan'], node: name }
      end

      def additional_dynamic_namespace
        { node: self }
      end

      def enabled_plugin_namespaces
        Plugins.activated.map do |plugin|
          Namespaces::Plugin.new(plugin, node: self) if plugin_enabled?(plugin)
        end.compact
      end

      def plugin_enabled?(plugin)
        answer.send(plugin.enabled_question_identifier)
      end
    end
  end
end
