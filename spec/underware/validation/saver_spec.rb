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

require 'underware/validation/saver'
require 'underware/validation/answer'
require 'underware/file_path'
require 'underware/data'
require 'underware/spec/alces_utils'

module SaverSpec
  module TestingMethods
    def input_test(*a)
      a
    end

    def data_test(*_a)
      data
    end
  end
end
Underware::Validation::Saver::Methods.prepend(SaverSpec::TestingMethods)

RSpec.describe Underware::Validation::Saver do
  include Underware::AlcesUtils

  let(:path) { Underware::FilePath }
  let(:saver) { described_class.new }
  let(:stubbed_answer_load) { OpenStruct.new(data: data) }
  let(:data) { { key: 'data' } }

  it 'errors if method is not defined' do
    expect do
      saver.not_found_methods('data')
    end.to raise_error(NoMethodError)
  end

  it 'errors if data is not included' do
    expect do
      saver.domain_answers
    end.to raise_error(Underware::SaverNoData)
  end

  it 'passes an arguments and data to the save method' do
    inputs = ['arg1', hash: 'value']
    expect(
      saver.input_test(data, *inputs)
    ).to eq(inputs)
    expect(
      saver.data_test(data, *inputs)
    ).to eq(data)
  end

  it 'calls the answer validator with the domain and data' do
    expect(Underware::Validation::Answer).to \
      receive(:new).with(data, answer_section: :domain)
                   .and_return(stubbed_answer_load)
    saver.domain_answers(data)
    expect(Underware::Data.load(path.domain_answers)).to eq(data)
  end
end
