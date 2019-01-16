
# frozen_string_literal: true

require 'shared_examples/hash_merger_namespace'
require 'shared_examples/namespace_hash_merging'
require 'underware/namespaces/alces'

RSpec.describe Underware::Namespaces::Domain do
  subject { alces.domain }

  context 'with AlcesUtils' do
    include Underware::AlcesUtils

    include_examples Underware::Namespaces::HashMergerNamespace

    before :each do
      # Create key pair files here (in production created on install), both so
      # can test in `#keys` (below) and so `HashMergerNamespace#to_h` tests
      # pass as key values will be included in hashed domain.
      Underware::Utils.create_file(
        Underware::FilePath.private_key, content: 'my_private_key'
      )
      Underware::Utils.create_file(
        Underware::FilePath.public_key, content: 'my_public_key'
      )
    end

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

    describe '#keys' do
      describe '#private' do
        it 'provides access to private key from file' do

          expect(subject.keys.private).to eq('my_private_key')
        end
      end

      describe '#public' do
        it 'provides access to public key from file' do

          expect(subject.keys.public).to eq('my_public_key')
        end
      end

      it 'errors if attempt to access any other properties' do
        expect { subject.keys.foo }.to raise_error(NoMethodError)
      end
    end
  end

  describe 'hash merging' do
    include_examples 'namespace_hash_merging',
      description: 'passes no extra parameters',
      expected_hash_merger_input: {}
  end
end
