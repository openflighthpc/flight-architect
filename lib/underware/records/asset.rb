# frozen_string_literal: true

require 'underware/records/record'

module Underware
  module Records
    class Asset < Record
      class << self
        def paths
          Dir.glob(FilePath.asset('[a-z]*', '*'))
        end

        def record_dir
          FilePath.assets_dir
        end
      end
    end
  end
end
