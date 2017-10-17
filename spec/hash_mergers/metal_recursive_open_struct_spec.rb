
# frozen_string_literal: true

require 'hash_mergers'
require 'config'
require 'filesystem'
require 'namespaces/alces'
require 'alces_utils'

module Metalware
  module Namespaces
    class Alces
      def testing; end
    end
  end
end

RSpec.describe Metalware::HashMergers::MetalRecursiveOpenStruct do
  include AlcesUtils

  AlcesUtils.mock self, :each { alces_default_to_domain_scope_off }

  let :alces do
    namespace = Metalware::Namespaces::Alces.new(metal_config)
    allow(namespace).to receive(:testing).and_return(build_default_hash)
    namespace
  end

  let :struct { build_default_hash }

  def build_default_hash
    my_hash = {
      key: 'value',
      erb1: '<%= alces.testing.key %>',
      erb2: '<%= alces.testing.erb1 %>',
      erb3: '<%= alces.testing.erb2 %>',
      erb4: '<%= alces.testing.erb3 %>',
      recursive_hash1: {
        recursive_hash2: '<%= alces.testing.key %>',
      },
    }
    build_hash(my_hash)
  end

  def build_hash(my_hash)
    Metalware::HashMergers::MetalRecursiveOpenStruct
      .new(my_hash) do |template_string|
      alces.render_erb_template(template_string)
    end
  end

  it 'does a single ERB replacement' do
    expect(struct.erb1).to eq('value')
  end

  it 'can replace multiple embedded erb' do
    expect(struct.erb4).to eq('value')
  end

  it 'can loop through the entire structure' do
    struct.each do |key, value|
      next if value.is_a? Metalware::HashMergers::MetalRecursiveOpenStruct
      exp = struct.send(key)
      msg = "#{key} was not rendered, expected: '#{exp}', got: '#{value}'"
      expect(exp).to eq(value), msg
    end
  end

  it 'renderes parameters in a recursive hash' do
    expect(struct.recursive_hash1.recursive_hash2).to eq('value')
  end

  context 'with array of hashes' do
    let :array_of_hashes do
      my_hash = {
        array: [
          { key: 'value' },
          { key: 'value' },
        ],
      }
      build_hash(my_hash)
    end

    it 'converts the hashes to own class' do
      expect(array_of_hashes.array).to be_a(Array)
      array_of_hashes.array.each do |arg|
        expect(arg).to be_a(Metalware::HashMergers::MetalRecursiveOpenStruct)
        expect(arg.key).to eq('value')
      end
    end
  end
end
