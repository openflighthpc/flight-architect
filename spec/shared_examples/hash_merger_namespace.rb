
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
      Underware::DataCopy.init_cluster(Underware::CommandConfig.load.current_cluster)
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
