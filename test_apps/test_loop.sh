#!/usr/bin/env bash

# Return a nanosecond clock compatible with CLOCK_MONOTONIC_RAW from clock_gettime()
function now() {
    sed -nE '/now/s/^now at ([0-9]+).*/\1/p' /proc/timer_list
}

[ $EUID -ne 0 ] && { echo "Must be root."; exit 1; }

taskset -cp 0 $$ &> /dev/null

taskset -c 0 ./log_freq.sh 1 traces 0.001 &
logger=$!

sleep 0.2

taskset -c 1 test_apps/loop > traces/events

sleep 0.2
kill -USR1 $logger
wait
