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

require 'underware/constants'
require 'underware/file_path'

RSpec.describe Underware::FilePath do
  describe 'dynamic constant paths' do
    let(:data_path) { Underware::Constants::UNDERWARE_DATA_PATH }

    it 'defines a constant file path' do
      expect(described_class.underware_data).to eq(data_path)
    end

    it 'does not define non-paths' do
      expect(described_class.respond_to?(:nodeattr_command)).to eq(false)
    end
  end
end
