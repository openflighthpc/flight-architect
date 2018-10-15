
# frozen_string_literal: true

module Underware
  module CliHelper
    module DynamicDefaults
      class << self
        delegate :build_interface, to: DeploymentServer
      end
    end
  end
end
