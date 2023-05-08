#!/bin/sh
##------------------------------------------------------------------------------
## Entrypoint for docker container
## 
## @author     Lars Thoms <lars@thoms.io>
## @date       2023-05-08
##------------------------------------------------------------------------------

##------------------------------------------------------------------------------
## Configuration
##------------------------------------------------------------------------------

# PID of application
PID_APP=0

# CMD of container
CMD="$*"

# Grace period of SIGTERM, until SIGKILL is triggered (in seconds)
TERMINATION_GRACE_PERIOD=30

# Watchdog interval, to detect a not running process (in seconds)
WATCHDOG_INTERVAL=10

# Exit code in case of an SIGTERM
EXIT_CODE=143


##------------------------------------------------------------------------------
## Boot
## 
## Copy configuration and modification files (e.g. theme adjustments) and
## set up the environment for the service.
##------------------------------------------------------------------------------

boot()
{
    . ./path.sh
    # Configure signal handlers
    trap 'SIGUSR1' USR1
    trap 'kill $!; SIGTERM' TERM
}


##------------------------------------------------------------------------------
## Start
## 
## Execute service binaries and schedulars.
##------------------------------------------------------------------------------

start()
{
    # Execute application
    {
        python3 subtitle2go.py /data/${CMD:-*.mp4}
        for file in /data/${CMD:-*.mp4}
        do
            if [ -f "$file" ]
            then
                ffmpeg -i "${file%.*}.vtt" "${file%.*}.srt"
                chmod --reference="${file}" "${file%.*}.vtt" "${file%.*}.srt"
                chown --reference="${file}" "${file%.*}.vtt" "${file%.*}.srt"
            fi
        done
    } &
    PID_APP=$!
}


##------------------------------------------------------------------------------
## Terminate
## 
## Kill the service with SIGTERM. If the process does not respond during
## the defined grace period, a SIGKILL will be sent.
##------------------------------------------------------------------------------

terminate()
{
    (sleep ${TERMINATION_GRACE_PERIOD}; kill -s KILL "$1") &
    kill -s TERM "$1" > /dev/null 2>&1
    wait "$1"
    code=$?

    if [ $? -lt ${code} ]
    then
        EXIT_CODE=${code}
    fi
}


##------------------------------------------------------------------------------
## Watchdog
## 
## In case of an absent service process the container will be halted gracefully.
##------------------------------------------------------------------------------

watchdog()
{
    while :
    do
        if kill -s 0 ${PID_APP} > /dev/null 2>&1
        then
            sleep ${WATCHDOG_INTERVAL} &
            wait $!
        else
            SIGTERM
        fi
    done
}


##------------------------------------------------------------------------------
## Signal handler
## 
## SIGUSR1: an user defined signal, which can be used for running adhoc tasks,
##          e.g. reloading configuration files or exporting data.
##
## SIGTERM: tell service processes to shutdown gracefully
##------------------------------------------------------------------------------

SIGUSR1()
{
    terminate ${PID_APP}

    start
}


SIGTERM()
{
    terminate ${PID_APP}

    exit ${EXIT_CODE}
}


##------------------------------------------------------------------------------
## Main
##------------------------------------------------------------------------------

cd /app

boot
start
watchdog
