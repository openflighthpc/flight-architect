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

require 'underware/spec/alces_utils'
require 'underware/constants'
require 'underware/dependency'

module Underware
  module SpecUtils
    # Mocks.

    def mock_validate_genders_success
      mock_validate_genders(true, '')
    end

    def use_mock_genders(genders_file: 'genders/default')
      genders_path = File.join(FIXTURES_PATH, genders_file)

      nodeattr_command = 'Underware::Constants::NODEATTR_COMMAND'
      stub_const(nodeattr_command, "nodeattr -f #{genders_path}")
    end

    def use_unit_test_config
      stub_const(
        'Underware::Constants::DEFAULT_CONFIG_PATH',
        fixtures_config('unit-test.yaml')
      )
    end

    def use_mock_determine_hostip_script
      stub_const(
        'Underware::Constants::UNDERWARE_INSTALL_PATH',
        FIXTURES_PATH
      )
    end

    def fake_download_error
      http_error = "418 I'm a teapot"
      allow(Underware::Input).to receive(:download).and_raise(
        OpenURI::HTTPError.new(http_error, nil)
      )
      http_error
    end

    # Other shared utils.

    def fixtures_config(config_file)
      File.join(FIXTURES_PATH, 'configs', config_file)
    end

    def enable_output_to_stderr
      $rspec_suppress_output_to_stderr = false
    end

    private

    def mock_validate_genders(valid, error)
      allow(Underware::NodeattrInterface).to receive(
        :validate_genders_file
      ).and_return([valid, error])
    end
  end
end
