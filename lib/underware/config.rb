# frozen_string_literal: true

#
# This file contains ruby configuration that should be constant
#

# Make 'chassis' both the singular and plural
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'chassis', 'chassis'
end
