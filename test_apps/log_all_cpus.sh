#!/usr/bin/env bash
set -x
[ $EUID -ne 0 ] && { echo "Must be root."; exit 1; }

taskset -cp 0 $$ &> /dev/null

pids=""
dirlist=""
N=$(nproc --all)
for ((i=0; i<N; i++)) ; do
    taskset -c 0 ./log_freq.sh $i traces_cpu$i 0.001 &
    pids+="$! "
    dirlist+="traces_cpu$i/events "
done

sleep 1

taskset -c 1 test_apps/loop 1 &
looper=$!

sleep 1

kill -9 $looper

sleep 1

kill -USR1 $pids
wait
