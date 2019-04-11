
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

require 'underware/command_helpers/base_command'
require 'underware/spec/alces_utils'

RSpec.describe Underware::UnderwareLog do
  describe '#warn' do
    # UnderwareLog receives `strict`/`quiet` from the command, so need to create a
    # 'real' command to use in tests.
    base_command = Underware::CommandHelpers::BaseCommand
    class Underware::Commands::TestCommand < base_command
      def run
        Underware::UnderwareLog.warn 'message'
      end
    end

    def run_test_command(**options)
      Underware::AlcesUtils.redirect_std(:stderr) do
        Underware::Utils.run_command(
          Underware::Commands::TestCommand, **options
        )
      end
    end

    let!(:output) do
      class_spy(Underware::Output).as_stubbed_const
    end

    let(:test_warning) { 'warning: message' }

    after do
      # Reset global options passed to UnderwareLog by command.
      described_class.strict = false
      described_class.quiet = false
    end

    xit 'gives warning output by default' do
      run_test_command
      expect(output).to \
        have_received(:stderr).with(test_warning)
    end

    xit 'only issues the warning once' do
      run_test_command
      run_test_command
      expect(output).to have_received(:stderr).once
    end

    xit 'does not give warning and raises when --strict passed' do
      expect_any_instance_of(Logger).not_to receive(:warn)
      expect do
        run_test_command(strict: true)
      end.to raise_error(Underware::StrictWarningError)

      expect(output).not_to \
        have_received(:stderr).with(test_warning)
    end

    xit 'does not give warning output when --quiet passed' do
      run_test_command(quiet: true)
      expect(output).not_to \
        have_received(:stderr).with(test_warning)
    end

    [true, false].each do |quiet|
      xit "logs warning to file when quiet=#{quiet}" do
        expect_any_instance_of(Logger).to receive(:warn).with('message')

        run_test_command(quiet: quiet)
      end
    end
  end
end
