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

require 'underware/overview/table'
require 'fixtures/shared_context/overview'

RSpec.describe Underware::Overview::Table do
  include_context 'overview context'

  let(:namespaces) { alces.groups }

  let(:table) do
    described_class.new(namespaces, fields).render
  end

  def header
    table.lines[1]
  end

  def body
    table.lines[3..-2].join("\n")
  end

  let(:headers) { fields.map { |h| h[:header] } }

  it 'includes the headers in the table' do
    headers.each do |h|
      expect(header).to include(h) unless h.nil?
    end
  end

  it 'includes the static value in the table' do
    expect(body).to include(static)
  end

  it 'renders the values' do
    expect(body).to include(config_value)
  end
end
