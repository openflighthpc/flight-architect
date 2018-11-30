
# frozen_string_literal: true

require 'underware/command_helpers/configure_command'
require 'underware/constants'

module Underware
  module Commands
    module Configure
      class Domain < CommandHelpers::ConfigureCommand
        private

        def answer_file
          FilePath.domain_answers
        end

        def configurator
          @configurator ||=
            Configurator.for_domain(alces)
        end
      end
    end
  end
end
