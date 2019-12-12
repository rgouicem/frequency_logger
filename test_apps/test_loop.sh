#!/usr/bin/env bash

[ $EUID -ne 0 ] && { echo "Must be root."; exit 1; }

taskset -c 0 ./log_freq.sh 1 traces 0.001 &
logger=$!

sleep 0.5

test_apps/loop.sh 1 &
echo "$(date +%s%N);start loop;green" >> traces/events
looper=$!

sleep 0.5
kill -9 $looper
echo "$(date +%s%N);kill loop;red" >> traces/events

sleep 0.5
kill -9 $logger
wait
