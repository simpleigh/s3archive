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
# Checks for the existence of a program
# @param string PROGRAM Program name
##
function environment_check_program {
    local PROGRAM="$1"
    
    which "$PROGRAM" > /dev/null
}


##
# Checks for the existence of a required program
# An error message will be displayed if the program isn't found.
# @param string PROGRAM Program name
##
function environment_require_program {
    local PROGRAM="$1"
    
    environment_check_program "$PROGRAM" || {
        echo "Error: program '$PROGRAM' could not be found."
        if [ -f /usr/lib/command-not-found ]; then
            /usr/lib/command-not-found "$PROGRAM"
        fi
        exit 21
    }
}


##
# Checks for the existence of a required file
# An error message will be displayed if the file isn't found.
# @param string FILE File name
##
function environment_require_file {
    local FILE="$1"
    
    if [ ! -f $FILE ]; then
        echo "Error: file '$FILE' could not be found."
        exit 22
    fi
}


##
# Checks for the existence of a required variable
# An error message will be displayed if the variable isn't found.
# @param string VARIABLE Variable name, as a string
# @param string HELP     Help message describing variable
##
function environment_require_variable {
    local VARIABLE="$1"
    local HELP="${2:-}"
    
    var_exists "$VARIABLE" || {
        echo "Error: variable '$VARIABLE' could not be found."
        if [ ! -z $HELP ]; then
            echo "$VARIABLE: $HELP"
        fi
        exit 23
    }
}


##
# Checks for the existence of an indexed array variable
# An error message will be displayed if the variable isn't found.
# @param string VARIABLE Variable name, as a string
# @param string HELP     Help message describing variable
##
function environment_require_variable_array_indexed {
    local VARIABLE="$1"
    local HELP="${2:-}"
    
    environment_require_variable "$VARIABLE"
    
    var_is_array_indexed "$VARIABLE" || {
        echo "Error: variable '$VARIABLE' should be an indexed array."
        if [ ! -z $HELP ]; then
            echo "$VARIABLE: $HELP"
        fi
        exit 24
    }
}


##
# Checks for the existence of an associative array variable
# An error message will be displayed if the variable isn't found.
# @param string VARIABLE Variable name, as a string
# @param string HELP     Help message describing variable
##
function environment_require_variable_array_assoc {
    local VARIABLE="$1"
    local HELP="${2:-}"
    
    environment_require_variable "$VARIABLE"
    
    var_is_array_assoc "$VARIABLE" || {
        echo "Error: variable '$VARIABLE' should be an associative array."
        if [ ! -z $HELP ]; then
            echo "$VARIABLE: $HELP"
        fi
        exit 25
    }
}
