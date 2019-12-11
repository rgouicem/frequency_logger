#!/usr/bin/env bash

[ $EUID -ne 0 ] && { echo "Must be root."; exit 1; }

./log_freq.sh 7 traces 0.001 &
logger=$!

sleep 0.1

test_apps/loop.sh 7 &
looper=$!

sleep 0.3
kill -9 $looper

sleep 0.3
kill -9 $logger
