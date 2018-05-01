# frozen_string_literal: true

require 'records/layout'
require 'records/asset'

module Metalware
  class AssetBuilder
    attr_reader :stack

    def initialize
      @stack ||= []
    end

    def push_asset(name, layout_or_type)
      if (details = source_file_details(layout_or_type))
        stack.push(Asset.new(name, details.path, details.type))
      else
        MetalLog.warn <<-EOF.squish
          Failed to add asset: "#{name}". Could not find layout:
          "#{layout_or_type}"
        EOF
      end
    end

    def pop_asset
      asset = stack.pop
      if asset.nil?
        nil
      elsif Records::Asset.available?(asset.name)
        asset
      else
        pop_asset
      end
    end

    private

    def source_file_details(layout_or_type)
      if Records::Asset::TYPES.include?(layout_or_type)
        OpenStruct.new(
          type: layout_or_type,
          path: FilePath.asset_type(layout_or_type)
        )
      elsif (path = Records::Layout.path(layout_or_type))
        OpenStruct.new(
          type: Records::Layout.type_from_path(path),
          path: path
        )
      end
    end

    Asset = Struct.new(:name, :source_path, :type) do
      def edit_and_save
        Utils::Editor.open_copy(source_path, asset_path) do |temp_path|
          validate_and_generate_sub_assets(temp_path)
        end
      end

      def save
        Utils.copy_via_temp_file(source_path, asset_path) do |path|
          unless validate_and_generate_sub_assets(path)
            raise_invalid_source
          end
        end
      end

      def asset_path
        FilePath.asset(type.pluralize, name)
      end

      private

      def raise_invalid_source
        raise ValidationFailure, <<-EOF.squish
          Failed to add asset: "#{name}". Please check the layout is valid:
          "#{source_path}"
        EOF
      end

      def validate_and_generate_sub_assets(path)
        if (data = Validation::Asset.valid_file?(path))
          new_data = convert_sub_assets(data)
          Metalware::Data.dump(path, new_data)
        end
      end

      def convert_sub_assets(value)
        case value
        when String
          convert_sub_asset_string(value)
        when Array
          value.map { |v| convert_sub_assets(v) }
        when Hash
          value.deep_merge(value) { |_,_, v| convert_sub_assets(v) }
        else
          value
        end
      end

      def convert_sub_asset_string(str)
        return str unless str.match?(/\A[^\^]+\^[^\^]+\Z/)
        # type = str.match(/\A.+(?=\^)/).to_s
        append_name = str.match(/(?<=\^).+\Z/).to_s
        "^#{name}_#{append_name}"
      end
    end
  end
end
