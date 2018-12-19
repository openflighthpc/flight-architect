# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
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
require 'underware/exceptions'
require 'underware/dependency'
require 'underware/constants'
require 'underware/validation/configure'
require 'ostruct'

require 'spec_helper'
require 'fileutils'
require 'underware/spec/alces_utils'

RSpec.describe Underware::Dependency do
  include Underware::AlcesUtils

  let(:command_input) { 'test' }

  def enforce_dependencies(dependency_hash)
    Underware::Dependency.new(
      command_input: command_input,
      dependency_hash: dependency_hash
    ).enforce
  end

  it 'fails when enforcing non-existent domain answer file presence, with error message telling you command to run' do
    # Note: here and in missing group answers error message, the command to
    # run includes `underware`, as no matter what tool the Dependency class
    # is being used from, namespace configuration still always occurs via
    # Underware.
    missing_domain_answers_error =
      /required answer file: domain\.yaml\. Please run 'underware configure domain'/

    expect do
      enforce_dependencies(
        configure: ['domain.yaml']
      )
    end.to raise_error(
      Underware::DependencyFailure, missing_domain_answers_error
    )
  end

  it 'fails when enforcing non-existent, non-orphan group answer file presence, with error message telling you command to run' do
    missing_group_answers_error =
      /required answer file: groups\/group1\.yaml\. Please run 'underware configure group group1'/

    expect do
      enforce_dependencies(
        configure: ['groups/group1.yaml']
      )
    end.to raise_error(
      Underware::DependencyFailure, missing_group_answers_error
    )
  end

  # The orphan group does not require an answer file
  it 'never fails when enforcing orphan group answer file presence' do
    expect do
      enforce_dependencies(
        configure: ['groups/orphan.yaml']
      )
    end.not_to raise_error
  end

  context 'when answer files exist' do
    before :each do
      FileSystem.setup do |fs|
        fs.with_answer_fixtures('answers/basic_structure')
      end
    end

    it 'succeeds when enforcing existent answer file presence' do
      expect do
        enforce_dependencies(
          configure: ['domain.yaml', 'groups/group1.yaml']
        )
      end.not_to raise_error
    end

    describe 'enforcing optional dependencies' do
      it 'succeeds when enforcing optional, non-existent answer file presence' do
        expect do
          enforce_dependencies(
            optional: {
              configure: ['not_found.yaml'],
            }
          )
        end.not_to raise_error
      end

      it 'succeeds when enforcing optional, existent answer file presence' do
        expect do
          enforce_dependencies(
            optional: {
              configure: ['domain.yaml', 'not_found.yaml'],
            }
          )
        end.not_to raise_error
      end
    end
  end
end
