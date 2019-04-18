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

require 'underware/underware_log'
require 'underware/exceptions'
require 'underware/validation/loader'
require 'underware/file_path'
require 'underware/namespaces/alces'
require 'underware/command_helpers/clusters'

module Underware
  module CommandHelpers
    class BaseCommand
      def self.options
        Commander::Command::Options.new
      end

      def self.register_dependency(&b)
        dependencies << b
      end

      def self.dependencies
        @dependencies ||= begin
          self == BaseCommand ? [] : self.superclass.dependencies.dup
        end
      end

      # Must be included after the class methods have been defined
      include CommandHelpers::Clusters

      def start(args, **options)
        run!(args, options)
      rescue Interrupt => e
        handle_interrupt(e)
      rescue IntentionallyCatchAnyException => e
        handle_fatal_exception(e)
      end

      def run!(args, options)
        pre_setup(args, options)
        setup
        run_dependencies
        run
      end

      attr_reader :args, :options

      private

      # `config` is a heavily used term in underware so it is safest
      # just to use the double underscore method
      def __config__
        @__config__ ||= CommandConfig.load
      end

      def global_setup(options)
        setup_global_log_options(options)
        log_command
      end

      def pre_setup(args, options)
        @args = args
        @options = OpenStruct.new(options)
      end

      def run_dependencies
        self.class.dependencies.each { |d| instance_exec(&d) }
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

      # Interrupt needs to re-raised as a StandardError, to prevent the traceback
      # from being dumped
      def handle_interrupt
        raise CaughtInterrupt, 'Received interrupt, exiting...'
      end

      def handle_fatal_exception(e)
        UnderwareLog.fatal e.inspect
        raise e
      end
    end
  end
end
