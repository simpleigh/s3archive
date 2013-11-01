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
set -o errexit


##
# Loads all required AWS credentials
# Starts with config file credentials, and queries instance metadata if needed.
# @param string FILENAME Config file location
##
function config_load {
    local FILENAME="$1"
    
    environment_require_file "$FILENAME"
    environment_require_program 'curl'
    environment_require_program 'sed'
    
    # Assemble a regex to parse config file
    local space='[[:blank:]]*'
    local varname='[[:alpha:]_][[:alnum:]_]*'
    local vardata='[[:alnum:]/+=._-]+'
    local variable="(${vardata})|('${vardata}')|(\"${vardata}\")"
    local regex="^${space}(${varname})${space}=${space}(${variable})${space}"
    
    # Load environment variables from config file
    local line
    for line in $(sed -rn "/${regex}/s//\1=\2/p" < "$FILENAME"); do
        eval "$line"
    done
    
    # Check for required variables
    environment_require_variable 'AWS_BUCKET_NAME'
    
    # Find a set of credentials
    if [ ! $(var_exists 'AWS_ROLE_NAME') ]; then
        environment_require_variable 'AWS_ACCESS_KEY_ID'
        environment_require_variable 'AWS_SECRET_ACCESS_KEY'
    else
        local url="http://instance-data/latest/meta-data/iam/security-credentials/${AWS_ROLE_NAME}"
        local metadata=$(curl --silent "$url")
        
        AWS_ACCESS_KEY_ID=$(     echo $metadata | sed -r 's/.*"AccessKeyId"\s*:\s*"([^"]+)".*/\1/')
        AWS_SECRET_ACCESS_KEY=$( echo $metadata | sed -r 's/.*"SecretAccessKey"\s*:\s*"([^"]+)".*/\1/')
        AWS_SECURITY_TOKEN=$(    echo $metadata | sed -r 's/.*"Token"\s*:\s*"([^"]+)".*/\1/')
    fi
}
