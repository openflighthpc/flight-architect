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
require 'logger'
require 'underware/exceptions'
require 'fileutils'
require 'underware/output'
require 'underware/file_path'

module Underware
  class UnderwareLog < Logger
    class << self
      # Having these global properties on the UnderwareLog class is pretty ugly,
      # but for legacy reasons we need to be able to call methods on the
      # UnderwareLog class directly all over the place, and this is the best way I
      # can see right now to share the values for `strict` and `quiet` set at
      # the top level in BaseCommand with all UnderwareLog instances without having
      # to completely refactor our use of UnderwareLog throughout Underware.
      attr_accessor :strict, :quiet

      def method_missing(s, *a, &b)
        underware_log.respond_to?(s) ? underware_log.public_send(s, *a, &b) : super
      end

      def underware_log
        @underware_log ||= UnderwareLog.new('underware')
      end
    end

    def initialize(log_name)
      file = "#{FilePath.logs_dir}/#{log_name}.log"
      FileUtils.mkdir_p File.dirname(file)
      f = File.open(file, 'a')
      f.sync = true
      super(f)
      self.level = Constants::LOG_SEVERITY
    end

    def warn(msg)
      raise StrictWarningError, msg if strict?
      print_warning(msg)
      super(msg)
    end

    private

    def strict?
      self.class.strict
    end

    def quiet?
      self.class.quiet
    end

    def print_warning(msg)
      return if quiet?
      message_cache[msg] ||= 0
      message_cache[msg] += 1
      return if message_cache[msg] > 1
      Output.stderr "warning: #{msg}"
    end

    def message_cache
      @message_cache ||= {}
    end
  end
end
