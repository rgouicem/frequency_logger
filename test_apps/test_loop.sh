#!/usr/bin/env bash

[ $EUID -ne 0 ] && { echo "Must be root."; exit 1; }

taskset -c 0 ./log_freq.sh 1 traces 0.001 &
logger=$!

sleep 0.5

test_apps/loop.sh 1 &
looper=$!

sleep 0.5
kill -9 $looper

sleep 0.5
kill -9 $logger
wait
