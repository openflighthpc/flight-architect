# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Metalware.
#
# Alces Metalware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Metalware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Metalware, please visit:
# https://github.com/alces-software/metalware
#==============================================================================

require 'command_helpers/base_command'
require 'command_helpers/node_identifier'
require 'config'

module Metalware
  module Commands
    module Orchestrate
      class Create < CommandHelpers::BaseCommand
        private

        prepend CommandHelpers::NodeIdentifier

        def setup; end

        def run
          if options.group
            nodes.each do |node|
              create(node)
            end
          else
            create(node.name)
          end
        end

        def node_info
          {
            libvirt_host: node.answer.libvirt_host
          }
        end

        def create(node)
          libvirt = Metalware::Vm.new(node_info[:libvirt_host], node, node.answer.vm_disk_pool)
          libvirt.create(render_template(node.name, 'disk'), render_template(node.name, 'vm'))
        end

        def object
          options.group ? group : node
        end

        def group
          alces.groups.find_by_name(args[0])
        end

        def node
          alces.nodes.find_by_name(node_names[0])
        end

        def node_names
          @node_names ||= nodes.map(&:name)
        end

        def render_template(node, type)
          template_path = "/var/lib/metalware/repo/libvirt/#{type}.xml"
          template = File.read(template_path)
          node = alces.nodes.find_by_name(node)
          templater = node ? node : alces
          templater.render_erb_template(template)
        end
      end
    end
  end
end
