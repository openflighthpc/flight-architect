#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Metalware.
#
# Alces Metalware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Metalware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Metalware, please visit:
# https://github.com/alces-software/metalware
#==============================================================================

require 'metal_log'
require 'config'
require 'dependency'
require 'exceptions'

module Metalware
  module CommandHelpers
    class BaseCommand
      def initialize(args, options)
        pre_setup(args, options)
        setup(args, options)
        post_setup
        run
      rescue Interrupt => e
        handle_interrupt(e)
      rescue Exception => e
        handle_fatal_exception(e)
      end

      attr_reader :config

      private

      def pre_setup(args, options)
        setup_config(options)
        log_command
      end

      def post_setup
        enforce_dependency
      end

      def setup_config(options)
        cli_options = {
          strict: !!options.strict,
          quiet: !!options.quiet
        }
        @config = Config.new(options.config, cli_options)
      end

      def dependency_hash
        {}
      end

      def enforce_dependency
        Dependency.new(config, command_name, dependency_hash).enforce
      end

      def command_name
        class_name_parts = self.class.name.split('::')
        parts_without_namespace = \
          class_name_parts.slice(2, class_name_parts.length)
        parts_without_namespace.join(' ').downcase.to_sym
      end

      def log_command
        MetalLog.info "metal #{ARGV.join(" ")}"
      end

      def setup(args, options)
        raise NotImplementedError
      end

      def run
        raise NotImplementedError
      end

      def handle_interrupt(e)
        raise e
      end

      def handle_fatal_exception(e)
        MetalLog.fatal e.inspect
        raise e
      end
    end
  end
end
