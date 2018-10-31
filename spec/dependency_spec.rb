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

  let(:filesystem) { FileSystem.setup }

  def enforce_dependencies(dependency_hash)
    filesystem.test do |_fs|
      Underware::Dependency.new(
        command_input: 'test',
        repo_path: Underware::FilePath.repo,
        dependency_hash: dependency_hash
      ).enforce
    end
  end

  context 'with a fresh filesystem' do
    it 'fails when enforcing repo dependencies' do
      expect do
        enforce_dependencies(repo: [])
      end.to raise_error(Underware::DependencyFailure)
    end

    it 'fails when enforcing configure dependencies' do
      expect do
        enforce_dependencies(configure: ['domain.yaml'])
      end.to raise_error(Underware::DependencyFailure)
    end
  end

  context 'with repo present' do
    before do
      filesystem.with_repo_fixtures('repo')
    end

    it 'succeeds when enforcing base repo presence' do
      expect do
        enforce_dependencies(repo: [])
      end.not_to raise_error
    end

    it 'succeeds when enforcing existent repo template presence' do
      expect do
        enforce_dependencies(repo: ['dependency-test1/default'])
      end.not_to raise_error
      expect do
        template = ['dependency-test1/default', 'dependency-test2/default']
        enforce_dependencies(repo: template)
      end.not_to raise_error
    end

    it 'fails when enforcing non-existent repo template presence' do
      expect do
        enforce_dependencies(repo: ['dependency-test1/not-found'])
      end.to raise_error(Underware::DependencyFailure)
    end

    it 'fails when enforcing repo directory presence' do
      expect do
        enforce_dependencies(repo: ['dependency-test1'])
      end.to raise_error(Underware::DependencyFailure)
    end

    it 'fails when enforcing non-existent regular answer file presence' do
      filesystem.test do
        expect do
          enforce_dependencies(
            configure: ['domain.yaml', 'groups/group1.yaml']
          )
        end.to raise_error(Underware::DependencyFailure)
      end
    end

    # The orphan group does not require an answer file
    it 'never fails when enforcing orphan group answer file presence' do
      filesystem.test do
        expect do
          enforce_dependencies(
            configure: ['groups/orphan.yaml']
          )
        end.not_to raise_error
      end
    end

    context 'when answer files exist' do
      before do
        filesystem.with_minimal_repo
        filesystem.with_answer_fixtures('answers/basic_structure')
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
end
