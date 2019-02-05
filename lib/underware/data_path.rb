# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019 Stephen F. Norledge and Alces Software Ltd.
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

module Underware
  class DataPath
    def self.cluster(cluster)
      new(cluster: cluster)
    end

    def self.overlay(overlay)
      new(overlay: overlay)
    end

    def initialize(cluster: nil, base: nil, overlay: nil)
      @base = if base
                base
              elsif cluster
                File.join(Config.storage_path, 'clusters', cluster)
              else
                overlay ||= 'base'
                File.join(Config.install_path, 'data', overlay)
              end
    end

    attr_reader :base

    def join(*join_path)
      File.join(base, *join_path.flatten.map(&:to_s))
    end

    # Generate static path methods
    {
      configure: ['etc', 'configure.yaml']
    }.each do |method, path|
      define_method(method) { join(path) }
    end

    # Generate directory path methods
    {
      template: ['lib', 'templates'],
      plugin: ['lib', 'plugins'],
      rendered: ['var', 'rendered']
    }.each do |method, path|
      define_method(method) { |*a| join(path, *a) }
    end

    # Add the rendered file helper methods
    [:platform, :core].each do |helper|
      define_method(:"rendered_#{helper}") do |scope, *a, **h|
        if scope.to_s == 'domain'
          rendered(scope, helper, *a)
        elsif h.key?(:name)
          rendered(scope, h[:name], helper, *a)
        else
          raise InternalError, ':name input is missing'
        end
      end
    end

    # Generate named yaml path methods
    {
      data_config: ['etc', 'data']
    }.each do |method, path|
      define_method(method) do |name|
        join(*Array.wrap(path), "#{name}.yaml")
      end
    end

    # Generate domain_/group_/node_/platform_ path methods
    # NOTE: Should 'platform' methods live here or in 'named yaml' above?
    {
      answers: ['var', 'answers'],
      config: ['etc', 'configs']
    }.each do |method, path|
      define_method(:"domain_#{method}") { join(path, 'domain.yaml') }
      ['group', 'node', 'platform'].each do |type|
        define_method(:"#{type}_#{method}") do |name|
          join(path, type.pluralize, "#{name}.yaml")
        end
      end
    end
  end
end
