
# frozen_string_literal: true

require 'shared_examples/hash_merger_namespace'
require 'shared_examples/namespace_hash_merging'
require 'underware/namespaces/alces'

RSpec.describe Underware::Namespaces::Domain do
  subject { alces.domain }

  context 'with AlcesUtils' do
    include Underware::AlcesUtils

    include_examples Underware::Namespaces::HashMergerNamespace

    context 'with mocked ip' do
      let(:ip) { '1.2.3.4' }

      before do
        allow(Underware::DeploymentServer).to receive(:ip).and_return(ip)
      end

      it 'has a hostip' do
        expect(subject.hostip).to eq(ip)
      end

      it 'has a hosts_url' do
        url = "http://#{ip}/metalware/system/hosts"
        expect(subject.hosts_url).to eq(url)
      end

      it 'has a genders_url' do
        url = "http://#{ip}/metalware/system/genders"
        expect(subject.genders_url).to eq(url)
      end
    end
  end

  describe 'hash merging' do
    include_examples 'namespace_hash_merging',
      description: 'passes no extra parameters',
      expected_hash_merger_input: {}
  end
end
