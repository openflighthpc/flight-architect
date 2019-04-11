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

require 'underware/commands'
require 'underware/cli_helper/dynamic_defaults'

module Underware
  module CliHelper
    CONFIG_PATH = File.join(File.dirname(__FILE__), 'config.yaml')

    class Parser
      def initialize(calling_obj = nil)
        @calling_obj = calling_obj

        # NOTE: Now that Underware has a `Data` module the majority of yaml
        # handling occurs through that.
        # CliHelper and autocomplete are exceptions as they should only ever be
        # altered by developers and need to load the file as is, instead of
        # Underware altering it to what it thinks it needs to be.
        @yaml = YAML.load_file(CONFIG_PATH)
      end

      def parse_commands
        @yaml['commands'].each do |command, attributes|
          parse_command_attributes(command, attributes)
        end
        @yaml['global_options'].each do |opt|
          @calling_obj.global_option(*opt['tags'], opt['description'].chomp)
        end
      end

      private

      def parse_command_attributes(command, attributes)
        @calling_obj.command command do |c|
          attributes.each do |a, v|
            next if a == 'autocomplete'
            case a
            when 'action'
              c.action { |args, opts| run_command(eval(v), args, opts) }
            when 'options'
              v.each do |opt|
                if [:Integer, 'Integer'].include? opt['type']
                  opt['type'] = 'OptionParser::DecimalInteger'
                end
                c.option(*opt['tags'],
                         eval(opt['type'].to_s),
                         { default: parse_default(opt) },
                         (opt['description']).to_s.chomp)
              end
            when 'subcommands'
              c.sub_command_group = true
              v.each do |subcommand, subattributes|
                subattributes[:sub_command] = true
                subcommand = "#{command} #{subcommand}"
                parse_command_attributes(subcommand, subattributes)
              end
            when 'examples'
              v.each { |e| c.example(*e) }
            else
              c.send("#{a}=", v.respond_to?(:chomp) ? v.chomp : v)
            end
          end
        end
      end

      def parse_default(opt)
        default_value = opt['default']
        if default_value.is_a? Hash
          dynamic_default_method = default_value['dynamic']
          DynamicDefaults.send(dynamic_default_method)
        else
          default_value
        end
      end

      #
      # Runs the command by extracting the options from from Commander::Options
      #
      def run_command(command, args, options)
        opt_hash = setup_and_strip_globals(options)
        command.new.start(args, **opt_hash)
      end

      def setup_and_strip_globals(commander_options)
        commander_options.__hash__.symbolize_keys.tap do |options|
          UnderwareLog.strict = !!options.delete(:strict)
          UnderwareLog.quiet = !!options.delete(:quiet)
        end
      end
    end
  end
end
