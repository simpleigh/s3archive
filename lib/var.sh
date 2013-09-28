#!/bin/bash
##
# S3 Archive - Library
#
# @author Leigh Simpson <code@simpleigh.com>
# @copyright Copyright © 2013, Leigh Simpson
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or any
# later version.
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
# License for more details.
#
# A copy of the GNU Lesser General Public License is available within
# COPYING.LGPL; alternatively write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
##

set -o pipefail
set -o nounset


##
# Checks whether a variable exists
# @param string VARIABLE Variable name, as a string
##
function var_exists {
    local VARIABLE="$1"
    
    declare -p "$VARIABLE" > /dev/null 2>&1
}


##
# Checks whether a variable is an array
# @param string VARIABLE Variable name, as a string
##
function var_is_array {
    local VARIABLE="$1"
    
    environment_require_program grep
    
    declare -p "$VARIABLE" 2> /dev/null | grep -q 'declare -[aA]'
}


##
# Checks whether a variable is an indexed array
# @param string VARIABLE Variable name, as a string
##
function var_is_array_indexed {
    local VARIABLE="$1"
    
    environment_require_program grep
    
    declare -p "$VARIABLE" 2> /dev/null | grep -q 'declare -a'
}


##
# Checks whether a variable is an associative array
# @param string VARIABLE Variable name, as a string
##
function var_is_array_assoc {
    local VARIABLE="$1"
    
    environment_require_program grep
    
    declare -p "$VARIABLE" 2> /dev/null | grep -q 'declare -A'
}
