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
require 'alces/tools/execution'
require 'alces/stack/iterator'
require 'timeout'

module Alces
  module Stack
    module Status
      class Task
        class << self
          def get_timeout
            Alces::Stack::Log.warn "Timeout not specified, using default" if @time.nil?
            @time ||= 10
          end

          def set_timeout(time)
            @time = time
          end
        end

        include Alces::Tools::Execution

        def initialize(node, job)
        end

        def fork!
          @read, @write = IO.pipe
          @pid = fork do 
            @read.close
            start
          end
          @write.close
          return self
        end

        def wait
          Process.waitpid(@pid)
        end

        def read
          @read.read
        end

        def pid; @pid; end

        # ----- FORKED METHODS BELOW THIS LINE ------
        
        def write(msg)
          @write.puts msg
        end

        def start
          timeout(time)
        rescue StandardError => e
          Alces::Stack::Log.error e.inspect
          raise e
        end

        def job_power_status(nodename)
          result = `#{ENV['alces_BASE']}/bin/metal power #{nodename} status 2>&1`
                     .scan(/Chassis Power is .*\Z/)[0].to_s
                     .scan(Regexp.union(/on/, /off/))[0]
          result.nil? ? "error" : result
        end

        def job_ping_node(nodename)
          result = `ping -c 1 #{nodename} > /dev/null; echo $?`
          result.chomp == "0" ? "ok" : "error"
        end
      end
    end
  end
end
