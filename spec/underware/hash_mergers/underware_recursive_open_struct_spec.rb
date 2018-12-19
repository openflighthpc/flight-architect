
# frozen_string_literal: true

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
    build_struct(default_table)
  end

  let :default_table do
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

  def build_struct(table)
    Underware::HashMergers::UnderwareRecursiveOpenStruct
      .new(table) do |template_string|
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
      build_struct(table)
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
    subject { inherited_class.new(data) }

    let(:data) { { sub_hash: { key: 'value' } } }
    let(:inherited_class) do
      Underware::TestInheritedUnderwareRecursiveOpenStruct
    end

    it 'returns sub hashes of that class' do
      expect(subject.sub_hash).to be_a(inherited_class)
    end
  end
end
