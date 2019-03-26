
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

require 'erb'

module Underware
  module Templating
    module Renderer
      class << self
        def replace_erb_with_binding(template, binding)
          # This mode allows templates to prevent inserting a newline for a
          # given line by ending the ERB tag on that line with `-%>`.
          trim_mode = '-'

          safe_level = 0
          erb = ::ERB.new(template, safe_level, trim_mode)

          begin
            erb.result(binding)
          rescue SyntaxError => error
            handle_error_rendering_erb(template, error)
          end
        end

        private

        def handle_error_rendering_erb(template, error)
          Output.stderr "\nRendering template failed!\n\n"
          Output.stderr "Template:\n\n"
          Output.stderr_indented_error_message template
          Output.stderr "\nError message:\n\n"
          Output.stderr_indented_error_message error.message
          abort
        end
      end
    end
  end
end
