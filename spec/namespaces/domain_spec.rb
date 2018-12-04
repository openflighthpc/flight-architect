
# frozen_string_literal: true

require 'shared_examples/hash_merger_namespace'
require 'shared_examples/namespace_hash_merging'
require 'underware/namespaces/alces'

RSpec.describe Underware::Namespaces::Domain do
  context 'with AlcesUtils' do
    include Underware::AlcesUtils

    subject { alces.domain }

    include_examples Underware::Namespaces::HashMergerNamespace

    before { use_mock_determine_hostip_script }

    it 'has a hostip' do
      expect(alces.domain.hostip).to eq('1.2.3.4')
    end

    it 'has a hosts url' do
      url = 'http://1.2.3.4/metalware/system/hosts'
      expect(alces.domain.hosts_url).to eq(url)
    end

    it 'has a genders url' do
      url = 'http://1.2.3.4/metalware/system/genders'
      expect(alces.domain.genders_url).to eq(url)
    end
  end

  describe 'hash merging' do
    subject { alces.domain }

    let :alces do
      Underware::Namespaces::Alces.new(platform: platform)
    end

    include_examples 'namespace_hash_merging',
      description: 'passes no extra parameters',
      expected_hash_merger_input: {}
  end
end
