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

require 'underware/file_path'
require 'underware/validation/loader'
require 'underware/data'
require 'underware/constants'

module Underware
  module HashMergers
    class HashMerger
      # NOTE: `_args` argument is needed so child classes can take their own
      # arguments and then call `super`.
      def initialize(*_args, eager_render:)
        @loader = Validation::Loader.new
        @cache = {}
        @eager_render = eager_render
      end

      def merge(groups: [], node: nil, platform: nil, &templater_block)
        arr = hash_array(groups: groups, node: node, platform: platform)
        UnderwareRecursiveOpenStruct.new(
          combine_hashes(arr), eager_render: eager_render, &templater_block
        )
      end

      private

      attr_reader :loader, :cache, :eager_render

      # Method to be overridden with the hash defaults
      def defaults
        {}
      end

      ##
      # hash_array enforces the order in which the hashes are loaded, it is
      # not responsible for how the file is loaded as that is delegated to
      # load_yaml
      #
      def hash_array(groups:, node:, platform:)
        [defaults, cached_yaml(:domain)].tap do |arr|
          groups.reverse.each do |group|
            arr.push(cached_yaml(:group, group))
          end

          arr.push(cached_yaml(:node, node)) if node
          arr.push(cached_yaml(:platform, platform)) if platform
        end
      end

      def cached_yaml(section, section_name = nil)
        begin
          data = cached_data(section, section_name)
          return data if data
          data = load_yaml(section, section_name)
          add_cached_data(section, section_name, data)
          data
        end.deep_dup
      end

      def cached_data(section, section_name)
        if section_name
          cache_section = cache[section]
          return nil unless cache_section
          cache_section[section_name]
        else
          no_section_name = cache[:no_section_name]
          return nil unless no_section_name
          no_section_name[section]
        end
      end

      def add_cached_data(section, section_name, data)
        if section_name
          cache[section] = {} unless cache[section]
          cache[section][section_name] = data
        else
          cache[:no_section_name] = {} unless cache[:no_section_name]
          cache[:no_section_name][section] = data
        end
      end

      def load_yaml(_section, _section_name)
        raise NotImplementedError
      end

      def combine_hashes(hashes)
        hashes.each_with_object({}) do |config, combined_config|
          config = config.dup # Prevents the cache being deleted
          raise CombineHashError unless config.is_a? Hash
          combined_config.deep_merge!(config)
        end
      end
    end
  end
end
