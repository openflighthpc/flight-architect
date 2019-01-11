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

require 'underware/hash_mergers'
require 'underware/spec/alces_utils'
require 'underware/data'
require 'underware/file_path'

RSpec.describe Underware::HashMergers::Answer do
  include Underware::AlcesUtils

  let(:group) { Underware::AlcesUtils.mock(self) { mock_group('new_group') } }
  let(:node) do
    Underware::AlcesUtils.mock(self) { mock_node('new_node', group.name) }
  end

  let(:identifier) { :question_identifier }
  let(:questions) do
    {
      domain: [{
        identifier: identifier.to_s,
        question: 'Ask domain question?',
        default: 'domain-default',
      }],
      group: [{
        identifier: identifier.to_s,
        question: 'Ask group question?',
        default: 'group-default', # Should be ignored
      }],
      node: [{
        identifier: identifier.to_s,
        question: 'Ask node question?',
        default: 'node-default', # Should be ignored
      }],
    }
  end

  def answers(namespace)
    case namespace
    when Underware::Namespaces::Domain
      'domain_answer'
    when Underware::Namespaces::Group
      'group_answer'
    when Underware::Namespaces::Node
      'node_answer'
    else
      raise 'unexpected error'
    end
  end

  before do
    Underware::Data.dump Underware::FilePath.configure, questions
  end

  shared_examples 'run contexts with shared' do |spec_group|
    context 'when loading domain answers' do
      subject { alces.domain }

      include_examples spec_group
    end

    context 'when loading group answers' do
      subject { group }

      include_examples spec_group
    end

    context 'when loading node answers' do
      subject { node }

      include_examples spec_group
    end
  end

  context 'without answer files' do
    shared_examples 'uses the domain default' do
      it 'uses the domain default' do
        expect(subject.answer.send(identifier)).to eq('domain-default')
      end
    end
    include_examples 'run contexts with shared', 'uses the domain default'
  end

  context 'with answer files' do
    before do
      Underware::Data.dump(
        Underware::FilePath.domain_answers,
        identifier => answers(alces.domain)
      )
      Underware::Data.dump(
        Underware::FilePath.group_answers(group.name),
        identifier => answers(group)
      )
      Underware::Data.dump(
        Underware::FilePath.node_answers(node.name),
        identifier => answers(node)
      )
    end

    shared_examples 'uses the saved answer' do
      it 'uses the saved answer' do
        expect(subject.answer.send(identifier)).to eq(answers(subject))
      end
    end
    include_examples 'run contexts with shared', 'uses the saved answer'
  end
end
