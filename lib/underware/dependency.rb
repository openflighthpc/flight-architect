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
require 'underware/constants'
require 'underware/validation/loader'

module Underware
  class Dependency
    def initialize(cluster:, command_input:, dependency_hash: {})
      @dependency_hash = dependency_hash
      @optional_dependency_hash = @dependency_hash.delete(:optional)
      @optional_dependency_hash ||= {}
      @command = command_input
      @cluster = cluster
    end

    def enforce
      run_dependencies(@dependency_hash)
      run_dependencies(@optional_dependency_hash, true)
    end

    private

    attr_reader :command, :cluster

    def run_dependencies(dep_hash, optional = false)
      dep_hash.each do |dep, values|
        unless values.is_a?(Array)
          msg = "Dependency values must be an array, check: #{dep}"
          raise DependencyInternalError, msg
        end
        send(:"validate_#{dep}")
        values.each { |value| validate_dependency_value(dep, value, optional) }
      end
    end

    def validate_dependency_value(dep, value, optional)
      unless valid_file?(dep, value)
        if optional
          return
        else
          raise DependencyFailure, get_value_failure_message(dep, value)
        end
      end

      case dep
      when :configure
        validate_answer_file(value)
      end
    end

    def validate_answer_file(relative_path)
      case relative_path
      when 'local.yaml'
        loader.local_answers
      when 'domain.yaml'
        loader.domain_answers
      when /^groups\/.+/
        filename = relative_path.sub('groups/', '')
        loader.group_answers(filename)
      when /^nodes\/.+/
        filename = relative_path.sub('nodes/', '')
        loader.node_answers(filename)
      else
        msg = "Can not determine question section for #{relative_path}"
        raise DependencyInternalError, msg
      end
    end

    def validate_configure
      @validate_configure ||= begin
        loader.question_tree
        unless valid_file?(:configure, '', true)
          msg = "Could not locate answer files: #{FilePath.answers_dir}"
          raise DependencyFailure, msg
        end
        true # Sets the @validate_configure value so it only runs once
      end
    end

    def valid_file?(dep, value, validate_directory = false, &block)
      path = begin
        case dep
        when :configure
          # Configuration happens in Underware, so always check Underware paths
          # when checking `configure` dependencies.
          File.join(FilePath.answers_dir, value)
        else
          msg = "Could not generate file path for dependency #{dep}"
          raise DependencyInternalError, msg
        end
      end

      if validate_directory
        Dir.exist?(path)
      # The orphan group's answer file is always optional
      elsif (path == FilePath.group_answers('orphan')) && !File.file?(path)
        true
      elsif File.file?(path)
        block.nil? ? true : !!(yield path)
      else
        false
      end
    end

    def get_value_failure_message(dep, value)
      msg = "The '#{dep}' dependency (value: #{value}) has failed"
      case dep
      when :configure
        cmd = File.basename(value, '.yaml')
        cmd = "group #{cmd}" unless cmd == 'domain'
        msg = "Could not locate required answer file: #{value}. Please run " \
              "'underware configure #{cmd}'"
      end
      msg
    end

    def loader
      @loader ||= Validation::Loader.new(cluster)
    end
  end
end
