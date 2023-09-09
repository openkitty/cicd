#!/bin/bash
# Copyright 2023 The Openkitty Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

# Color
Red='\e[0;31m'                 # Red
Green='\e[0;32m'               # Green
BRed='\e[1;31m'                # Red
BGreen='\e[1;32m'              # Green
BYellow='\e[1;33m'             # Yellow
BCyan='\e[1;36m'               # Cyan
Purple='\e[0;35m'              # Purple
BPurple='\e[1;35m'             # Bold Purple
Color_Off='\e[0m'              # Text Reset
Color_Off2="${Color_Off}\n"


#######
# Log #
#######
# Log head
function LOG_HEAD() {
    local assert_msg=${1}
    #echo -e "\n${BGreen}[INFO] ${assert_msg}${Color_Off}"
    printf "\n${BGreen}[INFO] ${assert_msg}${Color_Off2}"
}

# Log info
function LOG_INFO() {
    local assert_msg=${1}
    #echo -e "[INFO] ${assert_msg}"
    printf "${BGreen}[INFO] ${assert_msg}\n"
}

# Log info
function LOG_WARN() {
    local assert_msg=${1}
    #echo -e "[INFO] ${assert_msg}"
    printf "${BYellow}[WARNNING] ${assert_msg}\n"
}

# Log error
function LOG_ERROR() {
    local assert_msg=${1}
    #echo -e "${BRed}[ERROR] ${assert_msg}${Color_Off}"
    printf "${BRed}[ERROR] ${assert_msg}${Color_Off2}"
}

# Log command
function LOG_CMD() {
   local cmd="$*"
   #echo -e "${BPurple}[Command]${Color_Off} ${Purple}${cmd}${Color_Off}"
   printf "${BPurple}[Command]${Color_Off} ${Purple}${cmd}${Color_Off2}"
}

# Print and execute command
function LOG_DO() {
   local cmd="$*"
   #echo -e "${BPurple}[Command]${Color_Off} ${Purple}${cmd}${Color_Off}"
   printf "${BPurple}[Command]${Color_Off} ${Purple}${cmd}${Color_Off2}"
   ${cmd}
}


##########
# Assert #
##########
# Assert A is equal to B
# True: equal
# False: not equal
function DP_ASSERT_EQUAL() {
    local actual_value=${1}
    local expect_value=${2}
    local assert_msg=${3}
    local log_flag=${4:-"true"}
    local log_path=${5}
    if [ "${actual_value}" != "${expect_value}" ]; then
        if [ -n "${log_path}" ] && [ -f "${log_path}" ]; then
            cat ${log_path}
        fi
        LOG_ERROR "${assert_msg} is failed, the actual value is ${actual_value}."
        exit 1
    else
        if [ "${log_flag}" = "true" ]; then
            LOG_INFO "${assert_msg} is success."
        fi
    fi
}

# Assert A is not equal to B
# True: not equal
# False: equal
function DP_ASSERT_NOT_EQUAL() {
    local actual_value=${1}
    local expect_value=${2}
    local assert_msg=${3}
    local log_flag=${4:-"true"}
    local log_path=${5}
    if [ "${actual_value}" = "${expect_value}" ]; then
        if [ -n "${log_path}" ] && [ -f "${log_path}" ]; then
            cat ${log_path}
        fi
        LOG_ERROR "${assert_msg} is failed, the actual value is ${actual_value}."
        exit 1
    else
        if [ "${log_flag}" = "true" ]; then
            LOG_INFO "${assert_msg} is success."
        fi
    fi
}


########
# File #
########
# Check to see if the file exist
function DP_ASSERT_FILE () {
    local file_path=${1}
    if [ ! -f "${file_path}" ]; then
        LOG_ERROR "File(${file_path}) does not exist."
        exit 1
    fi
}

# Check to see if the file empty
function DP_ASSERT_FILE_EMPTY () {
    local file_path=${1}
    if [ ! -s "${file_path}" ]; then
        LOG_ERROR "File(${file_path}) is empty."
        exit 1
    fi
}

# Check to see if the directory exist
function DP_ASSERT_DIRECTORY () {
    local dir_path=${1}
    if [ ! -d "${dir_path}" ]; then
        LOG_ERROR "Directory(${dir_path}) does not exist."
        exit 1
    fi
}


#############
# Parameter #
#############
# Check to see if the string empty
function DP_ASSERT_STRING_EMPTY() {
    local var=${1}
    if [ -z "${var}" ]; then
        LOG_ERROR "String is empty."
        exit 1
    fi
}

# Check parameter
# bool_empty: whether the parameter is allowed to be empty. Default: true
function CHECK_PARAMETER() {
    local current_param=${1}
    local param_name=${2}
    local param_list=${3}
    local bool_empty=${4:-"true"}
    local flag_check=1
    local param=""
    
    # If in the parameter list
    for param in ${param_list//,/ }; do
        if [ "${current_param}" = "${param}" ]; then
            flag_check=0
            break
        fi
    done
    
    # If empty
    if [ "${bool_empty}" = "true" ] && [ -z "${current_param}" ]; then
        flag_check=0
    fi
    
    # Check result
    if [ "${flag_check}" = "1" ];then
        LOG_ERROR "Input parameter of ${param_name} is invalid. (Value: ${param_list})"
        exit 1
    fi
}


#########
# Print #
#########
# Print N character
function PRINT_N_CHAR() {
    local char=${1}
    local number=${2}
    local str=$(printf "%-${number}s" "")
    echo "${str// /${char}}"
}

# Remove part of string
# Example: 
#     orginal string: /usr/local/cmake/bin:/usr/local/python/python375/bin:/usr/local/bin
#     remove string: /usr/local/python/python375/bin
#     new string: /usr/local/cmake/bin:/usr/local/bin
function MS_REMOVE_PART_ENV_STRING() {
    local string=${1}
    local substring=${2}
    echo $(new=$(echo ${string}|tr ":" "\n"|grep -v "${substring}"|tr "\n" ":"); echo ${new%:})
}
