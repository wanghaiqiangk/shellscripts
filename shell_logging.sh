#!/bin/bash

function INFO
{
    local msg="$1"
    local color="\033[32m"
    local reset="\033[0m"
    printf "$(date "+%Y-%m-%d %H:%M:%S")  [${color}INFO${reset}] $$ : ${msg}\n"
}

function DEBUG
{
    if [ ${verbose:-0} -eq 0 ] ; then
        return
    fi
    local msg="$1"
    local color="\033[0m"
    local reset="\033[0m"
    printf "$(date "+%Y-%m-%d %H:%M:%S") [${color}DEBUG${reset}] $$ : ${msg}\n"
}

function WARN
{
    local msg="$1"
    local color="\033[33m"
    local reset="\033[0m"
    printf "$(date "+%Y-%m-%d %H:%M:%S")  [${color}WARN${reset}] $$ : ${msg}\n"
}

function FATAL
{
    local msg="$1"
    local exitstatus=$2
    local color="\033[31m"
    local reset="\033[0m"
    printf "$(date "+%Y-%m-%d %H:%M:%S") [${color}FATAL${reset}] $$ : ${color}${msg}${reset}\n"
    exit ${exitstatus:-1}
}
