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

require 'underware/system_command'

RSpec.describe Underware::SystemCommand do
  it 'runs the command and returns stdout' do
    expect(
      described_class.run('echo something')
    ).to eq "something\n"
  end

  context 'when command fails' do
    it 'raises' do
      expect do
        described_class.run('false')
      end.to raise_error Underware::SystemCommandError
    end

    it 'formats the error displayed to users when `format_error` is true' do
      begin
        described_class.run('false', format_error: true)
      rescue Underware::SystemCommandError => e
        expect(e.message).to match(/produced error/)
      end
    end

    it 'does not format the error when `format_error` is false' do
      begin
        described_class.run('false', format_error: false)
      rescue Underware::SystemCommandError => e
        expect(e.message).not_to match(/produced error/)
      end
    end
  end
end
