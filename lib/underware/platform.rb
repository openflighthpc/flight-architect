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

require 'ruby-progressbar'

require 'underware/template'

module Underware
  Platform = Struct.new(:cluster, :name) do
    def self.all(cluster)
      glob = DataPath.cluster(cluster).platform_config('*')
      Pathname.glob(glob).map do |config_path|
        provider_name = config_path.basename.sub_ext('').to_s
        new(cluster, provider_name)
      end.sort_by(&:name)
    end

    def render_templates
      namespaces.each do |namespace|
        render_templates_for_namespace(namespace)
        progress_bar.increment
      end
    end

    private

    def progress_bar
      @progress_bar ||=
        ProgressBar.create(
          title: name,
          total: namespaces.length,
          output: $stderr
      )
    end

    def namespaces
       @namespaces ||= [alces.domain] + alces.groups + alces.nodes
    end

    def alces
      @alces ||= Namespaces::Alces.new(platform: name)
    end

    def render_templates_for_namespace(namespace)
      scope_type = namespace.scope_type
      templates = platform_templates[scope_type] + content_templates[scope_type]
      templates.each { |template| template.render_for(namespace) }
    end

    def platform_templates
      # We cache this so we only load the platform templates once when a single
      # Platform instance is reused to render for multiple namespaces.
      @platform_templates ||=
        Template.all_under_directory(cluster, name)
    end

    def content_templates
      # Similarly cache this, though since content templates are shared between
      # platforms these may still be loaded multiple times, once per Platform
      # instance which is rendered against.
      @content_templates ||=
        Template.all_under_directory(cluster, Constants::CONTENT_DIR_NAME)
    end
  end
end
