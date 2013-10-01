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
# Initialises all global variables
# @global array REQUEST_Headers All request headers
##
function request_initialise {
    var_exists REQUEST_Headers && unset REQUEST_Headers
    declare -Ag REQUEST_Headers
    
    request_add_header 'Date' "$(date '+%a, %d %b %Y %-H:%M:%S %z')"
}


##
# Adds a header to the request
# @param string NAME  Header name
# @param string VALUE Header value
##
function request_add_header {
    local NAME="$1"
    local VALUE="$2"
    
    environment_require_variable_array_assoc 'REQUEST_Headers'
    
    REQUEST_Headers["$NAME"]="$VALUE"
}


##
# Signs the request headers
# See http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html
# The Authorization header will be added to the headers array.
# Not supported:
#  - more than one header with the same name
#  - headers spanning multiple lines
# @param  string AWS_ACCESS_KEY  Access key ID
# @param  string AWS_SECRET_KEY  Secret access key
# @param  string VERB            Request method
# @param  string BUCKET          Bucket name
# @param  string OBJECT          Object within bucket (optional)
# @global array  REQUEST_Headers All request headers
##
function request_sign {
    local AWS_ACCESS_KEY="$1"
    local AWS_SECRET_KEY="$2"
    local VERB="$3"
    local BUCKET="$4"
    local OBJECT="${5:-}"
    
    environment_require_variable_array_assoc 'REQUEST_Headers'
    environment_require_program 'openssl'
    environment_require_program 'base64'
    
    local STRING=''
    
    # HTTP-Verb
    STRING+="$VERB"
    STRING+=$'\n'
    
    # Content-MD5
    STRING+="${REQUEST_Headers[Content-MD5]:-}"
    STRING+=$'\n'
    
    # Content-Type
    STRING+="${REQUEST_Headers[Content-Type]:-}"
    STRING+=$'\n'
    
    # Date
    STRING+="${REQUEST_Headers[Date]}"
    STRING+=$'\n'
    
    # CanonicalizedAmzHeaders
    local AMZHEADERS=()
    for HEADER in ${!REQUEST_Headers[*]}; do
        if [[ "${HEADER,,}" =~ 'x-amz-' ]]; then
            AMZHEADERS+=("$HEADER")
        fi
    done
    
    if [ ${#AMZHEADERS[*]} -gt 0 ]; then
        # Array keys already come back sorted, but I can't find this documented
        (for I in ${AMZHEADERS[*]}; do echo $I; done) |
            sort |
            readarray -t AMZHEADERS
        
        for AMZHEADER in ${AMZHEADERS[*]}; do
            STRING+="${AMZHEADER,,}:"
            STRING+="${REQUEST_Headers[$AMZHEADER]}"
            STRING+=$'\n'
        done
    fi
    
    # CanonicalizedResource
    STRING+="/$BUCKET/$OBJECT"
    
    # Sign it
    local SIGNATURE=$(echo -n "$STRING" |
        openssl dgst -binary -hmac "$AWS_SECRET_KEY" -sha1 |
        base64)

    request_add_header 'Authorization' "AWS $AWS_ACCESS_KEY:$SIGNATURE"
}


##
# Makes a request
# @param  string VERB            Request method
# @param  string BUCKET          Bucket name
# @param  string OBJECT          Object within bucket (optional)
# @global array  REQUEST_Headers All request headers
##
function request_dispatch {
    local VERB="$1"
    local BUCKET="$2"
    local OBJECT="${3:-}"
    
    environment_require_variable_array_assoc 'REQUEST_Headers'
    environment_require_program 'curl'

    local COMMAND=$(which curl)
    COMMAND+=" --request '$VERB'"
    COMMAND+=" --show-error"
    COMMAND+=" --silent"
    for HEADER in ${!REQUEST_Headers[*]}; do
        COMMAND+=" --header '$HEADER: ${REQUEST_Headers[$HEADER]}'"
    done
    COMMAND+=" https://$BUCKET.s3.amazonaws.com/$OBJECT"
    
    echo "$COMMAND"
    $("$COMMAND")
}
