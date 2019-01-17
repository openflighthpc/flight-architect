# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
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

require 'underware/underware_log'
require 'underware/dependency'
require 'underware/exceptions'
require 'underware/dependency_specifications'
require 'underware/validation/loader'
require 'underware/file_path'
require 'underware/namespaces/alces'

module Underware
  module CommandHelpers
    class BaseCommand
      def self.options
        Commander::Command::Options.new
      end

      def initialize(args = [], options = nil, noop: false)
        unless noop
          options ||= self.class.options
          start(args, options)
        end
      end

      def start(args, options)
        global_setup(options)
        run!(args, options)
      rescue Interrupt => e
        handle_interrupt(e)
      rescue IntentionallyCatchAnyException => e
        handle_fatal_exception(e)
      end

      def run!(args, options)
        pre_setup(args, options)
        setup
        post_setup
        run
      end

      private

      attr_reader :args, :options

      def global_setup(options)
        setup_global_log_options(options)
        log_command
      end

      def pre_setup(args, options)
        @args = args
        @options = options
      end

      def post_setup
        enforce_dependency
      end

      def setup_global_log_options(options)
        UnderwareLog.strict = !!options.strict
        UnderwareLog.quiet = !!options.quiet
      end

      def dependency_specifications
        DependencySpecifications.new(alces)
      end

      def dependency_hash
        {}
      end

      def enforce_dependency
        Dependency.new(
          command_input: command_name,
          dependency_hash: dependency_hash
        ).enforce
      end

      def loader
        @loader ||= Validation::Loader.new
      end

      def command_name
        parts_without_namespace = \
          class_name_parts.slice(2, class_name_parts.length)
        parts_without_namespace.join(' ').to_sym
      end

      def class_name_parts
        Utils.class_name_parts(self)
      end

      def alces
        @alces ||= Namespaces::Alces.new(
          platform: platform_option,
          eager_render: options.render
        )
      end

      def reset_alces
        @alces = nil
      end

      def platform_option
        platform = options.platform
        return unless platform
        raise_if_unknown_platform(platform)
        platform
      end

      def raise_if_unknown_platform(platform)
        platform_config_path = FilePath.platform_config(platform)
        unless File.exist?(platform_config_path)
          message = "Unknown platform: #{platform} (#{platform_config_path} does not exist)"
          raise InvalidInput, message
        end
      end

      def log_command
        UnderwareLog.info "underware #{ARGV.join(' ')}"
      end

      # Setup can optionally be used to perform command-specific setup early on
      # in command execution.
      def setup; end

      def run
        raise NotImplementedError
      end

      def handle_interrupt(e)
        raise e
      end

      def handle_fatal_exception(e)
        UnderwareLog.fatal e.inspect
        raise e
      end
    end
  end
end
