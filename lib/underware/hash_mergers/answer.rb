
# frozen_string_literal: true

require 'underware/hash_mergers/hash_merger'

module Underware
  module HashMergers
    class Answer < HashMerger
      private

      def defaults
        alces.questions.root_defaults
      end

      def load_yaml(section, section_name)
        loader.section_answers(section, section_name)
      end
    end
  end
end
