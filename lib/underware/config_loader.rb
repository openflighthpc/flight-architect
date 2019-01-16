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

require 'underware/patches/tty_config'

module Underware
  module ConfigLoader
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def update(*a)
        new(*a).tap do |attr|
          read(attr)
          yield attr if block_given?
          write(attr)
        end
      end
      alias_method :load, :update

      private_class_method

      # NOTE: `read` and `write` are class methods are they are not intended
      # to be called directly. As these are file handling methods, they should
      # be called through the `update` mechanism
      def read(attr)
        return unless File.exists?(attr.path)
        attr.__data__.read(attr.path)
      end

      def write(attr)
        FileUtils.mkdir_p(File.dirname(attr.path))
        attr.__data__.write(attr.path, force: true)
      end
    end

    def __data__
      @__data__ ||= TTY::Config.new
    end

    def path
      raise NotImplementedError
    end
  end
end
