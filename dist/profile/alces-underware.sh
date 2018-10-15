#==============================================================================
# Copyright (C) 2007-2015 Stephen F. Norledge and Alces Software Ltd.
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
if [ "$UID" == "0" ]; then
    if [ -d /opt/underware/etc/profile.d ]; then
        for i in /opt/underware/etc/profile.d/*.sh ; do
            if [ -r "$i" ]; then
                if [ "${-#*i}" != "$-" ]; then
                    . "$i"
                else
                    . "$i" >/dev/null 2>&1
                fi
            fi
        done
    fi
    unset i
fi