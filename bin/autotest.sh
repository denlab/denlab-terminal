#!/bin/bash -e

#
# color: start
#
COLOR_RED='0;31'
COLOR_GREEN='0;32'
COLOR_NC='0'

WEIGHT_BOLD=$(tput bold)
WEIGHT_NC=$(tput sgr0)


function colorize {
    read IN
    COLOR=${1}
    echo -e '\033['${COLOR}'m'${IN}'\033['${COLOR_NC}'m'
}

function boldify {
    read IN
    echo -e ${WEIGHT_BOLD}${IN}${WEIGHT_NC}
}

function colorize_red {
    read IN
    echo -e ${IN} | colorize ${COLOR_RED}
}

function colorize_green {
    read IN
    echo -e ${IN} | colorize ${COLOR_GREEN}
}

function bold_green {
    read IN
    echo -e ${IN} | boldify | colorize_green
}

function bold_red {
    read IN
    echo -e ${IN} | boldify | colorize_red
}
#
# color: end
#

function line-msg-centered {
    MSG=" $1 "
    MSG_SIZE=${#MSG}
    COL_NUM=$(tput cols)
    HALF_SIZE=$((($COL_NUM - $MSG_SIZE) / 2))
    HALF=$(yes '-' | head -n $HALF_SIZE | tr -d '\n')
    RESULT="$HALF$MSG$HALF"
    echo "$RESULT"
}

function line-msg-left {
    MSG="$1 "
    MSG_SIZE=${#MSG}
    COL_NUM=$(tput cols)
    RIGHT_SIZE=$(($COL_NUM - $MSG_SIZE))
    RIGHT=$(yes '-' | head -n $RIGHT_SIZE | tr -d '\n')
    RESULT="$MSG$RIGHT"
    echo "$RESULT"
}

function echo-wait {
    line-msg-left "waiting for modications ..."
}

CMD=${1:-'./run.sh'}

while true
do
    set +e
    ${CMD}
    RETURN_CODE=$?
    if [[ $RETURN_CODE -eq 0 ]] # TODO could be simpler
    then
        echo "${CMD} Success!" | bold_green
    else
        echo "${CMD} Failure! return code=${RETURN_CODE}" | bold_red
    fi
    set -e
    echo-wait
    inotifywait -q -r -e close_write -e attrib -e move -e create -e delete --exclude '.*\.git.*|\.#.*' .
done
