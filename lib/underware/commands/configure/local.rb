
# frozen_string_literal: true

require 'underware/command_helpers/configure_command'
require 'underware/constants'

module Underware
  module Commands
    module Configure
      class Local < CommandHelpers::ConfigureCommand
        private

        def configurator
          @configurator ||=
            Configurator.for_local(alces)
        end

        def answer_file
          file_path.local_answers
        end
      end
    end
  end
end
