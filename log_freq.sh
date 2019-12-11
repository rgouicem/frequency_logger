#! /bin/bash

if [ $# -ne 1 ] && [ $# -ne 2 ] ; then
    echo "Usage: log_freq.sh cpu [interval]"
    exit 255
fi

[ $EUID -ne 0 ] && { echo "Run this with more privileges (root or sudo)"; exit 254; }

lsmod | grep -q -E '^msr ' || modprobe msr || { echo "You need the msr kernel module for this tool to work"; exit 253; }

### MSR definitions
IA32_MPERF=0xe7
IA32_APERF=0xe8

interval=0.1
[ -z $2 ] || interval=$2

# Usage: readfreq cpu
function readfreq {
    # Read MSRs and date
    d=$(date +%s%N)
    m=$(rdmsr -p$1 $IA32_MPERF -d)
    a=$(rdmsr -p$1 $IA32_APERF -d)

    # Drop overflowing values
    if [ $m -lt $lm ] || [ $a -lt $la ] ; then return; fi

    # Compute frequency and echo it
    (( dm = m - lm ))
    (( da = a - la ))
    (( freq = base_khz * da / dm ))
    lm=$m
    la=$a
    echo "$d;$freq"
}

# Get base freq
base_khz=$(cat /sys/devices/system/cpu/cpufreq/policy0/base_frequency)

lm=0
la=0
echo "time;frequency"
while : ; do
    readfreq $1
    sleep $interval
done
