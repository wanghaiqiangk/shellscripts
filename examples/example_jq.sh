#!/bin/bash

function showhelp
{
    cat<<EOF
Usage:
    ${0##*/} [-v] [-h] FILE1 FILE2

Description
    Given Glint SDK outputs FILE1 and FILE2, this program generates
markdown formatted results.

Options
    -v               verbose
    -h,--help        show this helpful message
EOF
    exit $1
}

source ${BASH_SOURCE%/*}/shell_logging.sh
verbose=0
shortoptstr="vh"
longoptstr="help"
opts=$(getopt -s bash -l "${longoptstr}" -- "${shortoptstr}" "$@") || exit 1
eval set -- "${opts}"
while : ; do
    case "$1" in
        -v)
            verbose=1; shift;;
        -h|--help)
            showhelp 0; shift;;
        --)
            shift; break;;
        *)
            showhelp 1; break;;
    esac
done

if [ $# -ne 2 ] ; then
    FATAL "No more arguments."
fi

compare_groundtruth=0
file1=$1
file2=$2
grep -q -Ei "ground|truth|expect" <<< ${file1} && compare_groundtruth=1
grep -q -Ei "ground|truth|expect" <<< ${file2} && compare_groundtruth=1
DEBUG "${compare_groundtruth}"

readonly improved="↑"
readonly declined="↓"
readonly good="✅"
readonly bad="❌"
readonly nochange="―"

declare -a markdown

poles=($(jq -r 'keys | @sh' ${file1} | tr -d \'))
for pole in ${poles[@]} ; do
    videolist=($(jq -r ".${pole} | keys | @sh" ${file1} | tr -d \'))
    DEBUG "${videolist[*]}"
    for videofile in ${videolist[@]} ; do
        markdown+=("## ${pole}-${videofile}\n")
        markdown+=("|Criteria|${file1}|${file2}|Status|")
        markdown+=("|---|---|---|---|")

        carNum1=$(jq -r ".${pole}.${videofile}.carNum | @sh" ${file1} | tr -d \')
        DEBUG "${carNum1}"
        carType1=$(jq -r ".${pole}.${videofile}.carType[] | @sh" ${file1} | tr '\n' ' ')
        DEBUG "${carType1}"
        yaw1=$(jq -r ".${pole}.${videofile}.yaw[] | @sh" ${file1} | tr '\n' ' ')
        DEBUG "${yaw1}"
        frameCnt1=($(jq -r ".${pole}.${videofile}.frameCnt[] | @sh" ${file1} | tr -d \'))
        DEBUG "${frameCnt1[*]}"
        aiFire1=($(jq -r ".${pole}.${videofile}.aiFire[] | @sh" ${file1} | tr -d \'))
        DEBUG "${aiFire1[*]}"

        carNum2=$(jq -r ".${pole}.${videofile}.carNum | @sh" ${file2} | tr -d \')
        DEBUG "${carNum2}"
        carType2=$(jq -r ".${pole}.${videofile}.carType[] | @sh" ${file2} | tr '\n' ' ')
        DEBUG "${carType2}"
        yaw2=$(jq -r ".${pole}.${videofile}.yaw[] | @sh" ${file2} | tr '\n' ' ')
        DEBUG "${yaw2}"
        frameCnt2=($(jq -r ".${pole}.${videofile}.frameCnt[] | @sh" ${file2} | tr -d \'))
        DEBUG "${frameCnt2[*]}"
        aiFire2=($(jq -r ".${pole}.${videofile}.aiFire[] | @sh" ${file2} | tr -d \'))
        DEBUG "${aiFire2[*]}"

        if [ ${carNum1} -eq ${carNum2} ] ; then
            markdown+=("|Car Number|${carNum1}|${carNum2}|${good}|")
            if [ "${carType1}" == "${carType2}" ] ; then
                markdown+=("|Car Type|${carType1}|${carType2}|${good}|")
            else
                markdown+=("|Car Type|${carType1}|${carType2}|${bad}|")
            fi
            if [ "${yaw1}" == "${yaw2}" ] ; then
                markdown+=("|Car Yaw|${yaw1}|${yaw2}|${good}|")
            else
                markdown+=("|Car Yaw|${yaw1}|${yaw2}|${bad}|")
            fi
            if [ ${compare_groundtruth} -eq 1 ] ; then
                markdown+=("|Frame Count|${frameCnt1[*]}|${frameCnt2[*]}|")
                for ((idx=0; idx<${#frameCnt1[@]}; idx++)) ; do
                    if [ ${frameCnt1[${idx}]} -lt ${frameCnt2[${idx}]} ] ; then
                        markdown[-1]+="${improved}"
                    elif [ ${frameCnt1[${idx}]} -gt ${frameCnt2[${idx}]} ] ; then
                        markdown[-1]+="${declined}"
                    else
                        markdown[-1]+="${nochange}"
                    fi
                done
                markdown[-1]+="|"

                markdown+=("|AI Count|${aiFire1[*]}|${aiFire2[*]}|")
                for ((idx=0; idx<${#aiFire1[@]}; idx++)) ; do
                    if [ ${aiFire1[${idx}]} -lt ${aiFire2[${idx}]} ] ; then
                        markdown[-1]+="${improved}"
                    elif [ ${aiFire1[${idx}]} -gt ${aiFire2[${idx}]} ] ; then
                        markdown[-1]+="${declined}"
                    else
                        markdown[-1]+="${nochange}"
                    fi
                done
                markdown[-1]+="|"
            fi

        else
            markdown+=("|Car Number|${carNum1}|${carNum2}|${bad}|")
        fi
        markdown[-1]+="\n"
    done
done

for line in "${markdown[@]}" ; do
    echo -e ${line}
done
