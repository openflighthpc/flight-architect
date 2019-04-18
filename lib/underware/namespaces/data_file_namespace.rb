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

require 'hashie'

module Underware
  module Namespaces
    class DataFileNamespace
      delegate :namespace_data_file, to: FilePath

      def method_missing(message, *_args)
        data_file_path = namespace_data_file(message)
        if respond_to?(message)
          Hashie::Mash.load(data_file_path)
        else
          # Normally `method_missing` should call `super` if it doesn't
          # `respond_to?` a message. In this case this is a namespace designed
          # to be used by users writing templates, so give them an informative
          # error message for what they've probably missed instead. This does
          # mean though that we could get a confusing error message if
          # something else goes wrong in this class, so I could eventually come
          # to regret this.
          raise UnderwareError, <<~ERROR.chomp
            "Requested data file doesn't exist: #{data_file_path}"
          ERROR
        end
      end

      def respond_to_missing?(message, _include_all = false)
        data_file_path = namespace_data_file(message)
        File.exist?(data_file_path)
      end
    end
  end
end
