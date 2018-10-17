
# frozen_string_literal: true

require 'underware/command_helpers/inspect_command'

module Underware
  module Commands
    class Eval < CommandHelpers::InspectCommand
      private

      attr_reader :command

      def setup
        @command = args.first
      end

      def run
        pretty_print_json(alces.instance_eval(command).to_json)
      end
    end
  end
end
