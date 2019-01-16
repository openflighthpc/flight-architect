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

    def self.layout(layout)
      new(layout: layout)
    end

    def initialize(cluster: nil, base: nil, layout: nil)
      @base = if base
                base
              elsif cluster
                File.join(Config.storage_path, 'clusters', cluster)
              else
                layout ||= 'base'
                File.join(Config.install_path, 'data', layout)
              end
    end

    attr_reader :base

    def relative(*relative_path)
      File.join(base, *relative_path)
    end

    # Generate static path methods
    {
      configure: 'configure.yaml',
      public_key: ['keys', 'id_rsa.pub'],
      private_key: ['keys', 'id_rsa']
    }.each do |method, path|
      define_method(method) { relative(*Array.wrap(path)) }
    end

    # Generate directory path methods
    {
      template: 'templates',
      layout: 'layouts',
      asset: 'assets',
      plugin: 'plugins',
      rendered: 'rendered'
    }.each do |method, path|
      define_method(method) { |*a| relative(*Array.wrap(path), *a) }
    end

    # Generate named yaml path methods
    {
      data_config: 'data'
    }.each do |method, path|
      define_method(method) do |name|
        relative(*Array.wrap(path), "#{name}.yaml")
      end
    end

    # Generate domain_/group_/node_/platform_ path methods
    # NOTE: Should 'platform' methods live here or in 'named yaml' above?
    {
      answers: 'answers',
      config: 'configs'
    }.each do |method, path|
      path = Array.wrap(path)
      define_method(:"domain_#{method}") { relative(path, 'domain.yaml') }
      ['group', 'node', 'platform'].each do |type|
        define_method(:"#{type}_#{method}") do |name|
          relative(path, type.pluralize, "#{name}.yaml")
        end
      end
    end
  end
end
