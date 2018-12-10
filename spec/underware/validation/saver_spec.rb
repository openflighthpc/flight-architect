# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Underware.
#
# Alces Underware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Underware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Underware, please visit:
# https://github.com/alces-software/underware
#==============================================================================

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