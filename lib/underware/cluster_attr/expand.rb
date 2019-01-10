# frozen_string_literal: true

##
# This module has been adapted from the Nodeattr Gem by Doug Everly, 2013
# https://github.com/DougEverly/nodeattr
#

# Copyright (c) 2013 Doug Everly

# MIT License

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Underware
  class ClusterAttr
    class Expand
      class << self
        def explode_nodes(nodes)
          h = Array.new
          m = nodes.match(/^(.*)\[(.*)\]$/)
          if m
            base = m[1]
            instances = m[2].split(',')
            instances.each do |i|
              if i.match(/-/)
                left, right = i.split('-')
                padding = left.match(/^0+/)
                (left.to_i .. right.to_i).each do |j|
                  h << sprintf("%s%0#{padding.to_s.length + 1}d", base, j)
                end
              else
                padding = i.match(/^0+/).size - 1
                if padding.size > 1
                  pad = '0' * (padding.size -1)
                end
                h << sprintf("%s%0#{padding.to_s.length + 1}d", base, j)
              end
            end
          end
          h
        end
      end
    end
  end
end
