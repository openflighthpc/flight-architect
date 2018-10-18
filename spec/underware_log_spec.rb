
# frozen_string_literal: true

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
      AlcesUtils.redirect_std(:stderr) do
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

    it 'gives warning output by default' do
      run_test_command
      expect(output).to \
        have_received(:warning).with(test_warning)
    end

    it 'only issues the warning once' do
      run_test_command
      run_test_command
      expect(output).to have_received(:warning).once
    end

    it 'does not give warning and raises when --strict passed' do
      expect_any_instance_of(Logger).not_to receive(:warn)
      expect do
        run_test_command(strict: true)
      end.to raise_error(Underware::StrictWarningError)

      expect(output).not_to \
        have_received(:warning).with(test_warning)
    end

    it 'does not give warning output when --quiet passed' do
      run_test_command(quiet: true)
      expect(output).not_to \
        have_received(:warning).with(test_warning)
    end

    [true, false].each do |quiet|
      it "logs warning to file when quiet=#{quiet}" do
        expect_any_instance_of(Logger).to receive(:warn).with('message')

        run_test_command(quiet: quiet)
      end
    end
  end
end
