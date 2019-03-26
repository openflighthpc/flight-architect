
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
