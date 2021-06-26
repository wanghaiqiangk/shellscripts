#!/bin/bash

set -e

# Shell checkout
shell_inuse=$(ps -o args= $$ | awk '{print $1}')
if [ "${shell_inuse}" != "bash" -a "${shell_inuse}" != "sh" ] ; then
    echo "Current shell: ${shell_inuse}"
    echo "Require for SH or BASH"
    exit 1
fi


# Constant variable definitions
readonly COLOR_RED="\033[31m"
readonly COLOR_GREEN="\033[32m"
readonly COLOR_YELLOW="\033[33m"
readonly COLOR_BLUE="\033[34m"
readonly COLOR_DEFAULT="\033[0m"
readonly LVL_DEBUG=0
readonly LVL_INFO=1
readonly LVL_WARN=2
readonly LVL_FATAL=3


# Configurations
dest=${dest:=/dev/stdout}
reset=${COLOR_DEFAULT}
color="placeholder"
reset_msg=${COLOR_DEFAULT}
color_msg=${COLOR_DEFAULT}
format="%Y-%m-%d %H:%M:%S"
level=${level:=${LVL_INFO}}

color_info=${COLOR_GREEN}
color_debug=${COLOR_DEFAULT}
color_fatal=${COLOR_RED}
color_warn=${COLOR_YELLOW}


LOG_WHERE ()
{
    local where="$1"
    if [ -n "${where}" ] ; then
        if [ -f "${where}" ] ; then
            rm "${where}"
        fi
    fi
    color=""
    reset=""
    reset_msg=""
    color_msg=""
    dest=${where}
    printf "Logging to %s\n" "${where}"
}

LOG_LEVEL ()
{
    local lvlname
    local priority="$1"
    case "${priority}" in
        0)
            lvlname=DEBUG ;;
        1)
            lvlname=INFO ;;
        2)
            lvlname=WARN ;;
        3)
            lvlname=FATAL ;;
        *)
            lvlname=UNKNOWN ;;
    esac

    if [ $level -lt $priority ] ; then
        level=$priority
        printf "%s\n" "Level increase to ${lvlname}"
    elif [ $level -gt $priority ] ; then
        printf "%s\n" "Level decrease to ${lvlname}"
        level=$priority
    else
        printf "%s\n" "Level not changed"
    fi
}

LOG_IMPL ()
{
    local msg="$1"
    local level="$2"
    local format="$3"
    local color="$4"
    local pid="$$"
    local color_msg="$5"

    { printf "%s " "$(date +"${format}")"
      printf "%d [%b%5s%b] : " ${pid} "${color}" "${level}" "${reset}"
      printf "%b%s%b\n" "${color_msg}" "${msg}" "${reset_msg}"
    } >> ${dest}
}

INFO ()
{
    if [ $level -le $LVL_INFO ] ; then
        LOG_IMPL "$*" INFO "${format}" ${color:+${color_info}} ${color_msg}
    fi
}

DEBUG ()
{
    if [ $level -le $LVL_DEBUG ] ; then
        LOG_IMPL "$*" DEBUG "${format}" ${color:+${color_debug}} ${color_msg}
    fi
}

WARN ()
{
    if [ $level -le $LVL_WARN ] ; then
        LOG_IMPL "$*" WARN "${format}" ${color:+${color_warn}} ${color_msg}
    fi
}

FATAL ()
{
    if [ $level -le $LVL_FATAL ] ; then
        LOG_IMPL "$*" FATAL "${format}" ${color:+${color_fatal}} ${color_msg:+${color_fatal}}
    fi
}
