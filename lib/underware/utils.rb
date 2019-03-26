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
  module Utils
    class << self
      def commentify(string, comment_char: '#', line_length: 80)
        comment_string = "#{comment_char} "
        max_commented_line_length = line_length - comment_string.length

        wrap(string, max_commented_line_length)
          .split("\n")
          .map { |line| line.prepend(comment_string) }
          .join("\n")
      end

      def run_command(command_class, *args, **options_hash)
        options = Commander::Command::Options.new
        options_hash.map do |option, value|
          option_setter = (option.to_s + '=').to_sym
          options.__send__(option_setter, value)
        end

        command_class.new(args, options)
      end

      def copy_via_temp_file(source, destination)
        temp_name = File.basename(destination, '.*')
        content = File.read(source)
        create_temp_file(temp_name, content) do |path|
          yield path
          FileUtils.cp(path, destination)
        end
      end

      def class_name_parts(object)
        object.class.to_s.downcase.split('::').map(&:to_sym)
      end

      # Create file at any path, optionally with some content, by first
      # creating every needed parent directory.
      def create_file(path, content: '')
        dir_path = File.dirname(path)
        FileUtils.mkdir_p(dir_path)
        File.write(path, content)
      end

      private

      # From
      # https://www.safaribooksonline.com/library/view/ruby-cookbook/0596523696/ch01s15.html.
      def wrap(string, width)
        string.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
      end

      def create_temp_file(name, content)
        file = Tempfile.new(name)
        file.write(content)
        file.flush
        yield file.path
      ensure
        file.close
        file.unlink
      end
    end
  end
end
