#!/usr/bin/env bash

# Usage:
#   loop.sh [cpulist]
#
#  Runs a single threaded infinite loop.
#  If cpulist is provided, the thread will be pinned to this cpulist.
#  Else, it will be free to use any cpu.

[ $# -lt 1 ] && cpulist="0-$(nproc)" || cpulist=$1

taskset -c -p ${cpulist} $$

while : ; do
    :
done
