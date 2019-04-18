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

module Underware
  module Plugins
    Plugin = Struct.new(:path) do
      delegate :domain_config,
               :group_config,
               :node_config,
               to: :config_path

      def name
        path.basename.to_s
      end

      def activated?
        Plugins.activated?(name)
      end

      def activated_identifier
        if activated?
          '[ACTIVATED]'.green
        else
          '[DEACTIVATED]'.red
        end
      end

      def activate!
        Plugins.activate!(name)
      end

      def configure_questions
        Plugins::ConfigureQuestionsBuilder.build(self)
      end

      def enabled_question_identifier
        Plugins.enabled_question_identifier(name)
      end

      private

      def config_path
        @config_path ||= DataPath.new(base: path)
      end
    end
  end
end
