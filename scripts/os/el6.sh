#==============================================================================
# Copyright (C) 2015 Stephen F. Norledge and Alces Software Ltd.
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
install_runtime_prerequisites() {
    # ruby: openssl readline zlib libffi
    yum -e0 -y install openssl readline zlib libffi && \
        yum -e0 -y install git
}

install_base_prerequisites() {
    yum -e0 -y install lsof
}

install_build_prerequisites() {
    # ruby: openssl readline zlib libffi
    yum -e0 -y groupinstall "Development Tools" && \
        yum -e0 -y install openssl-devel readline-devel zlib-devel libffi-devel
}
