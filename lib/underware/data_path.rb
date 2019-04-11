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
  class DataPath
    def self.cluster(cluster)
      new(cluster: cluster)
    end

    def self.overlay(overlay)
      new(overlay: overlay)
    end

    def initialize(cluster: nil, base: nil, overlay: nil)
      input = if base
                base
              elsif cluster
                File.join(Config.storage_path, 'clusters', cluster)
              else
                overlay ||= 'base'
                File.join(Config.install_path, 'data', overlay)
              end
      @base = Pathname.new(input)
    end

    attr_reader :base

    def join(*join_path)
      Pathname.new(File.join(base, *join_path.flatten.map(&:to_s)))
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

    # Helper function for finding a specific platform template
    def template_file(*parts, dir:, scope:)
      template(dir, scope, *parts)
    end

    # Add the rendered file helper methods
    def rendered_file(*a, name: nil, **h)
      raw_rendered_file(*a, name: name, **h).sub('__name__', name.to_s)
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

    private

    def raw_rendered_file(*parts, platform:, scope:, name: nil, core: false)
      section = core ? Constants::CONTENT_DIR_NAME : 'platform'
      if scope.to_s == 'domain'
        rendered(platform, scope, section, *parts)
      elsif name
        rendered(platform, scope, name, section, *parts)
      else
        raise InternalError, 'The name has not been set'
      end
    end
  end
end
