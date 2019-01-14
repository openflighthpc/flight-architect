# frozen_string_literal: true

#
# This file contains ruby configuration that should be constant
#

# Make 'chassis' both the singular and plural
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'chassis', 'chassis'
end

module Underware
  class Config
    def self.current_cluster
      Underware::Commands::Init::CLUSTER_IDENTIFIER
    end
  end
end
