#! /bin/bash

if [ $# -ne 2 ] && [ $# -ne 3 ] ; then
    echo "Usage: log_freq.sh cpu output_dir [interval]"
    exit 255
fi

[ $EUID -ne 0 ] && { echo "Run this with more privileges (root or sudo)"; exit 254; }

[ -d $2 ] && { echo "$output_dir already exists. Aborting."; exit 252; }
output_dir=$2

lsmod | grep -q -E '^msr ' || modprobe msr || { echo "You need the msr kernel module for this tool to work"; exit 253; }

interval=0.1
[ -z $3 ] || interval=$3

mkdir -p $output_dir

# Get base freq and other freqs
base_khz=$(echo "$(sed -nE '/model name/s/(.+) ([0-9.]+)GHz/\2/p' /proc/cpuinfo | head -n1) * 1000000" | bc)
base_khz=${base_khz%.*}
echo $base_khz > ${output_dir}/base_freq
cp /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq ${output_dir}/min_freq
cp /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq ${output_dir}/max_freq
cp /sys/devices/system/cpu/cpufreq/policy0/scaling_governor ${output_dir}/

# Start C utility
trap 'echo Killing readfreq...; kill -INT $!' SIGUSR1
./readfreq $1 $interval $base_khz > ${output_dir}/log &
wait
echo Terminating
