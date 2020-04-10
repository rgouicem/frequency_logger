#!/usr/bin/env bash

[ $EUID -ne 0 ] && { echo "Must be root."; exit 1; }

# Default duration of 200 ms
: ${DURATION:=200000000}

# Pin this script (and its children) to cpu0
taskset -cp 0 $$ &> /dev/null

# Launch logger on cpu0, monitoring cpu1
taskset -c 0 ./log_freq.sh 1 traces 0.001 &
logger=$!

sleep 0.2

# Launch a busy loop for DURATION ns
taskset -c 1 test_apps/loop $DURATION > traces/events

# Kill logger 200 ms after busy loop ended
sleep 0.2
kill -USR1 $logger
wait
