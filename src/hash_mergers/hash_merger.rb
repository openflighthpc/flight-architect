
# frozen_string_literal: true

require 'file_path'
require 'validation/loader'
require 'data'
require 'recursive-open-struct'
require 'constants'

module Metalware
  module HashMergers
    class HashMerger
      HASH_DATA_STRUCTURE = RecursiveOpenStruct

      def initialize(metalware_config, groups: [], node: nil)
        @metalware_config = metalware_config
        @file_path = FilePath.new(metalware_config)
        @loader = Validation::Loader.new(metalware_config)
        @groups = groups
        @node = node
      end

      def merge
        HASH_DATA_STRUCTURE.new(combine_hashes(hash_array))
      end

      private

      attr_reader :metalware_config, :file_path, :loader, :groups, :node

      ##
      # hash_array enforces the order in which the hashes are loaded, it is not
      # responsible for how the file is loaded as that is delegated to load_yaml
      #
      def hash_array
        [ load_yaml(:domain) ].tap do |arr|
          groups.each { |group| arr.push(load_yaml(:group, group)) }
          arr.push(load_yaml(:node, node)) if node
        end
      end

      def load_yaml(section, section_name = nil)
        raise NotImplementedError
      end

      def combine_hashes(hashes)
        hashes.each_with_object({}) do |config, combined_config|
          raise CombineHashError unless config.is_a? Hash
          combined_config.deep_merge!(config)
        end
      end
    end
  end
end