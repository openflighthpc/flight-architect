
# frozen_string_literal: true

module Underware
  # Class to generate reused `dependency_hash`s, for use by `Dependency` object
  # to enforce command dependencies.
  # XXX Consider moving generating of more `dependency_hash`s here.
  class DependencySpecifications
    def initialize(alces)
      @alces = alces
    end

    def for_node_in_configured_group(name)
      group = find_node(name).group
      {
        repo: ['configure.yaml'],
        configure: ['domain.yaml', "groups/#{group.name}.yaml"],
        optional: {
          configure: ["nodes/#{name}.yaml"],
        },
      }
    end

    private

    attr_reader :alces

    def find_node(name)
      node = alces.nodes.find_by_name(name)
      # XXX Does it make sense to raise this exception here? We raise the same
      # exception in `NodeattrInterface#genders_for_node`, and not sure if this
      # means the same thing; even if it does it's not at the same level of
      # abstraction.
      raise NodeNotInGendersError, "Could not find node: #{name}" unless node
      node
    end
  end
end
