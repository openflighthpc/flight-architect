
# frozen_string_literal: true

require 'underware/answers_table_creator'

module Underware
  module Commands
    module ViewAnswers
      class Domain < CommandHelpers::BaseCommand
        private

        def run
          puts AnswersTableCreator.new(alces).domain_table
        end

        def dependency_hash
          {
            configure: ['domain.yaml'],
          }
        end
      end
    end
  end
end
