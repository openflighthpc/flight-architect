
# frozen_string_literal: true

require 'underware/deployment_server'

module Underware
  module Namespaces
    class Local < Node
      class << self
        def create(*args)
          new(*args)
        end
      end
    end
  end
end
