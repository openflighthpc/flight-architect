
require 'tempfile'
require 'yaml'
require 'highline'

require 'configurator'


RSpec.describe Metalware::Configurator do
  let :highline {
    HighLine.new
  }

  let :configure_file {
    Tempfile.new('configure.yaml')
  }

  let :configure_file_path {
    configure_file.path
  }

  let :answers_file_path {
    Tempfile.new('test.yaml').path
  }

  let :answers {
    YAML.load_file(answers_file_path)
  }

  let :configurator {
    Metalware::Configurator.new(
      highline: highline,
      configure_file: configure_file_path,
      questions: 'test',
      answers_file: answers_file_path
    )
  }

  def define_questions(questions_hash)
    configure_file.write(questions_hash.to_yaml)
    configure_file.rewind
  end

  describe '#configure' do
    it 'asks questions with type `string`' do
      define_questions({
        test: {
          string_q: {
            question: 'Can you enter a string?',
            type: 'string'
          }
        }
      })

      expect(highline).to receive(
        :ask
      ).with(
        'Can you enter a string?'
      ).and_return(
        'My string'
      )

      configurator.configure

      expect(answers).to eq({
        'string_q' => 'My string'
      })
    end


    it 'asks questions with no `type` as `string`' do
      define_questions({
        test: {
          string_q: {
            question: 'Can you enter a string?'
          }
        }
      })

      expect(highline).to receive(
        :ask
      ).with(
        'Can you enter a string?'
      ).and_return(
        'My string'
      )

      configurator.configure

      expect(answers).to eq({
        'string_q' => 'My string'
      })
    end
  end
end
