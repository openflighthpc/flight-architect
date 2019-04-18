
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

require 'underware/namespaces/mixins/implicit_hasher'
require 'ostruct'

RSpec.describe Underware::Namespaces::Mixins::ImplicitHasher do
  let(:whitelist_double) do
    ctx = __binding__
    Class.new do
      include ctx.eval('described_class')

      ctx.eval('white_list').each do |method|
        define_method(method) { "#{method} - return" }
      end

      def recursive_hash_obj
        OpenStruct.new(am_i_a_ostuct: 'no, I should be a hash')
      end

      def array_method
        [OpenStruct.new(property: 'value_within_array_object')]
      end

      private

      def private_method
        'Do not hash me'
      end
    end
  end

  let(:test_obj) do
    whitelist_double.new
  end

  let(:white_list) { (1..3).map { |i| :"white_method#{i}" } }
  let(:recursive_white_list) { [:recursive_hash_obj] }
  let(:array_white_list) { [:array_method] }

  let(:test_hash) { test_obj.to_h }
  let(:expected_number_of_keys) do
    [
      white_list,
      recursive_white_list,
      array_white_list,
    ].map(&:length).reduce(&:+)
  end

  it 'has all the white listed methods' do
    expect(test_hash.keys).to include(*white_list)
  end

  it 'has the recursive listed methods' do
    expect(test_hash.keys).to include(*recursive_white_list)
  end

  it 'has recursive array listed methods as array of hashes' do
    expect(test_hash.keys).to include(*array_white_list)
    expect(test_hash[:array_method]).to eq [
      { property: 'value_within_array_object' },
    ]
  end

  it 'has the correct number of keys' do
    expect(test_hash.keys.length).to eq(expected_number_of_keys)
  end
end
