
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

require 'underware/exceptions'
require 'underware/templating/renderer'
require 'underware/hash_mergers'

module Underware
  module Namespaces
    class HashMergerNamespace
      include Mixins::ImplicitHasher
      attr_reader :name

      def initialize(alces, name = nil)
        @alces = alces
        @name = name
      end

      def config
        @config ||= run_hash_merger(alces.hash_mergers.config)
      end

      def answer
        @answer ||= run_hash_merger(alces.hash_mergers.answer)
      end

      def render_string(template_string, **dynamic_namespace)
        alces.render_string(
          template_string,
          **additional_dynamic_namespace,
          **dynamic_namespace
        )
      end

      def render_file(template_path, **dynamic_namespace)
        alces.render_file(
          template_path,
          **additional_dynamic_namespace,
          **dynamic_namespace
        )
      end

      def scope_type
        Utils.class_name_parts(self).last
      end

      private

      attr_reader :alces
      delegate :platform, to: :alces

      def run_hash_merger(hash_obj)
        hash_obj.merge(**hash_merger_input) do |template|
          render_string(template)
        end
      end

      def hash_merger_input
        if platform
          {platform: platform}
        else
          {}
        end
      end

      def additional_dynamic_namespace
        raise NotImplementedError
      end
    end
  end
end
