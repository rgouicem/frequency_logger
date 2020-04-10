#!/usr/bin/env bash

[ $EUID -ne 0 ] && { echo "Must be root."; exit 1; }

# Duration of idleness before busy loop in s (default: 200 ms)
: ${BEFORE:=0.2}
# Duration of busy loop in s (default: 200 ms)
: ${DURATION:=0.2}
# Duration of idleness after busy loop in s (default: 200 ms)
: ${AFTER:=0.2}

# Convert duration to ns for loop program
DURATION=$(echo "$DURATION * 1000000000 / 1" | bc)

# Pin this script (and its children) to cpu0
taskset -cp 0 $$ &> /dev/null

# Launch logger on cpu0, monitoring cpu1
taskset -c 0 ./log_freq.sh 1 traces 0.001 &
logger=$!

sleep $BEFORE

# Launch a busy loop for DURATION ns
taskset -c 1 test_apps/loop $DURATION > traces/events

# Kill logger AFTER seconds after busy loop ended
sleep $AFTER
kill -USR1 $logger
wait
