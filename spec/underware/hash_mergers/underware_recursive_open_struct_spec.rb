
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

require 'underware/hash_mergers'
require 'underware/namespaces/alces'
require 'underware/spec/alces_utils'

module Underware
  module Namespaces
    class Alces
      def testing; end
    end
  end
end

module Underware
  class TestInheritedUnderwareRecursiveOpenStruct < \
    Underware::HashMergers::UnderwareRecursiveOpenStruct
  end
end

RSpec.describe Underware::HashMergers::UnderwareRecursiveOpenStruct do
  let(:alces) do
    namespace = Underware::Namespaces::Alces.new
    allow(namespace).to receive(:testing).and_return(subject)
    namespace
  end

  let(:subject) do
    build_struct(default_table, eager_render: false)
  end

  let(:default_table) do
    {
      key: 'value',
      erb1: '<%= alces.testing.key %>',
      erb2: '<%= alces.testing.erb1 %>',
      erb3: '<%= alces.testing.erb2 %>',
      erb4: '<%= alces.testing.erb3 %>',
      recursive_hash1: {
        recursive_hash2: '<%= alces.testing.key %>',
      },
    }
  end

  def build_struct(table, eager_render:)
    Underware::HashMergers::UnderwareRecursiveOpenStruct
      .new(table, eager_render: eager_render) do |template_string|
      alces.render_string(template_string)
    end
  end

  it 'does a single ERB replacement' do
    expect(subject.erb1).to eq('value')
  end

  it 'can replace multiple embedded erb' do
    expect(subject.erb4).to eq('value')
  end

  it 'can loop through the entire structure' do
    subject.each do |key, value|
      next if value.is_a? described_class
      exp = subject.send(key)
      msg = "#{key} was not rendered, expected: '#{exp}', got: '#{value}'"
      expect(exp).to eq(value), msg
    end
  end

  it 'renderes parameters in a recursive hash' do
    expect(subject.recursive_hash1.recursive_hash2).to eq('value')
  end

  context 'with array of hashes' do
    let(:array_of_hashes) do
      table = {
        array: [
          { key: 'value' },
          { key: 'value' },
        ],
      }
      build_struct(table, eager_render: false)
    end

    it 'converts the hashes to own class' do
      expect(array_of_hashes.array).to be_a(Array)
      array_of_hashes.array.each do |arg|
        expect(arg).to be_a(described_class)
        expect(arg.key).to eq('value')
      end
    end
  end

  context 'when using an inherited class' do
    subject { inherited_class.new(data, eager_render: false) }

    let(:data) { { sub_hash: { key: 'value' } } }
    let(:inherited_class) do
      Underware::TestInheritedUnderwareRecursiveOpenStruct
    end

    it 'returns sub hashes of that class' do
      expect(subject.sub_hash).to be_a(inherited_class)
    end
  end

  describe '#to_h' do
    it 'by default returns the originally passed in table' do
      expect(subject.to_h).to eq(default_table)
    end

    context 'when eager_render passed when creating struct' do
      subject do
        build_struct(default_table, eager_render: true)
      end

      it 'recursively renders all values in table up-front' do
        expect(subject.to_h).to eq(
          {
            key: 'value',
            erb1: 'value',
            erb2: 'value',
            erb3: 'value',
            erb4: 'value',
            recursive_hash1: {
              recursive_hash2: 'value',
            },
          }
        )
      end
    end
  end
end
