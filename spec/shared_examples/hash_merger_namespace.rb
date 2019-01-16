
# frozen_string_literal: true

require 'underware/namespaces/alces'
require 'underware/spec/alces_utils'

RSpec.shared_examples \
  Underware::Namespaces::HashMergerNamespace do

  let(:test_config) do
    {
      test_config: 'I am the config',
    }
  end

  let(:test_answer) do
    { test_answer: 'I am the answer' }
  end

  describe '#to_h' do
    Underware::AlcesUtils.mock self, :each do
      Underware::DataCopy.init_cluster(Underware::Config.current_cluster)
      config(subject, test_config)
      answer(subject, test_answer)
    end

    it 'converts the config into a hash' do
      expect(subject.to_h[:config]).to eq(test_config)
    end

    it 'converts the answer into a hash' do
      expect(subject.to_h[:answer]).to eq(test_answer)
    end
  end

  describe '#scope_type' do
    it 'gives correct scope type' do
      expected_scope_type = case subject
                            when Underware::Namespaces::Domain
                              :domain
                            when Underware::Namespaces::Group
                              :group
                            when Underware::Namespaces::Node
                              :node
                            else
                              raise "Unhandled class: #{subject.class}"
                            end

      expect(subject.scope_type).to eq(expected_scope_type)
    end
  end
end
