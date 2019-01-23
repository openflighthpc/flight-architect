
# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019 Stephen F. Norledge and Alces Software Ltd.
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

require 'underware/namespaces/mixins/white_list_hasher'
require 'ostruct'

RSpec.describe Underware::Namespaces::Mixins::WhiteListHasher do
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
