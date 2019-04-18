
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

RSpec.describe Underware::CommandHelpers::ConfigureCommand do
  TEST_COMMAND_NAME = :testcommand

  # Subclass of `ConfigureCommand` for use in tests, to test it independently
  # of any individual subclass.
  class TestCommand < Underware::CommandHelpers::ConfigureCommand
    private

    # Overridden to be three element array with third a valid `configure.yaml`
    # questions section; `BaseCommand` expects command classes to be namespaced
    # by two modules.
    def class_name_parts
      [:some, :namespace, :test]
    end

    def answer_file
      Underware::FilePath.domain_answers
    end

    def configurator
      Underware::Configurator.new(alces, questions_section: :domain)
    end
  end

  describe 'option handling' do
    it 'passes answers through to configurator as hash' do
      Underware::DataCopy.init_cluster(Underware::CommandConfig.load.current_cluster)
      answers = { question_1: 'answer_1' }
      expect_any_instance_of(Underware::Configurator)
        .to receive(:configure).with(answers)

      Underware::Utils.run_command(TestCommand, answers: answers.to_json)
    end
  end
end
