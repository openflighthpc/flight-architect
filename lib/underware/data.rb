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
require 'yaml'
require 'underware/underware_log'

module Underware
  module Data
    class << self
      def log
        @log ||= UnderwareLog.new('file')
      end

      def load(data_file)
        log.info "load: #{data_file}"
        data = raw_load(data_file)
        process_loaded_data(data, source: data_file)
      rescue StandardError => e
        log.error("Fail: #{e.inspect}")
        raise e
      end

      def dump(data_file, data)
        raise dump_error(data) unless valid_data?(data)
        yaml = data.deep_transform_keys(&:to_s).to_yaml
        FileUtils.mkdir_p(File.dirname(data_file))
        File.write(data_file, yaml)
        log.info "dump: #{data_file}"
      end

      private

      def raw_load(data_file)
        if File.file? data_file
          YAML.load_file(data_file) || {}
        else
          log.info 'file not found'
          {}
        end
      end

      def process_loaded_data(data, source:)
        raise load_error(source) unless valid_data?(data)
        data.deep_transform_keys(&:to_sym)
      end

      def valid_data?(data)
        data.respond_to? :deep_transform_keys
      end

      def load_error(data_file)
        raise DataError, <<-EOF.squish
          Attempted to load invalid data from #{data_file};
          should contain a hash
        EOF
      end

      def dump_error(data)
        raise DataError, <<-EOF.squish
          Attempted to dump invalid data (#{data}); should be a hash
        EOF
      end
    end
  end
end
