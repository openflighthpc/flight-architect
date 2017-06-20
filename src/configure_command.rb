
require 'base_command'
require 'configurator'
require 'constants'

module Metalware
  class ConfigureCommand < BaseCommand
    def run
      configurator.configure
    end

    def handle_interrupt(_e)
      abort 'Exiting without saving...'
    end

    protected

    def answers_file
      raise NotImplementedError
    end

    private

    def configurator
      Configurator.new(
        highline: self,
        configure_file: config.configure_file,
        questions: questions_section,
        answers_file: answers_file
      )
    end

    def questions_section
      self.class.name.split('::')[-1].downcase.to_sym
    end
  end
end
