#! /bin/bash

if [ $# -ne 2 ] && [ $# -ne 3 ] ; then
    echo "Usage: log_freq.sh cpu output_dir [interval]"
    exit 255
fi

[ $EUID -ne 0 ] && { echo "Run this with more privileges (root or sudo)"; exit 254; }

[ -d $2 ] && { echo "$output_dir already exists. Aborting."; exit 252; }
output_dir=$2

lsmod | grep -q -E '^msr ' || modprobe msr || { echo "You need the msr kernel module for this tool to work"; exit 253; }

# Check if tsc_khz is available and warn if not
if [ -f /sys/devices/system/cpu/tsc_khz ] ; then
    tsc_khz=$(cat /sys/devices/system/cpu/tsc_khz)
else
    echo "[WARN} You don't have tsc_khz exported. The base_freq will be used instead."
    echo "Build and insert the tsc_khz module (in this repo's tsc_khz submodule) to remove this warning."
    tsc_khz=0
fi

interval=0.1
[ -z $3 ] || interval=$3

mkdir -p $output_dir

# Get base freq and other freqs
vendor=$(sed -nE '/vendor_id/s/.+: (.+)$/\1/p' /proc/cpuinfo | head -n1)
if [ "$vendor" == "GenuineIntel" ] ; then
    base_khz=$(echo "$(sed -nE '/model name/s/(.+) ([0-9.]+)GHz/\2/p' /proc/cpuinfo | head -n1) * 1000000" | bc)
    base_khz=${base_khz%.*}
elif [ "$vendor" == "AuthenticAMD" ] ; then
    # The base frequency should bo read from MSR registers as explained
    # in AMD's Processor Programming Reference:
    # https://developer.amd.com/wp-content/resources/55570-B1_PUB.zip
    # But I'm way too tired to do it properly, so just use the max
    # frequency from sysfs since it is the same on my test CPU.
    # This also means that max frequency does not take Boost into account...
    # Don't know how to get this boosted value, thanks AMD...
    base_khz=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq)
else
    echo "Vendor $vendor not supported. Aborting."
    rm -rf $output_dir
    exit 251
fi
echo $base_khz > ${output_dir}/base_freq
echo $tsc_khz > ${output_dir}/tsc_khz
cp /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq ${output_dir}/min_freq
cp /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq ${output_dir}/max_freq
cp /sys/devices/system/cpu/cpufreq/policy0/scaling_governor ${output_dir}/

# Start C utility
trap 'echo Killing readfreq...; kill -INT $!' SIGUSR1
./readfreq $1 $interval $base_khz > ${output_dir}/log &
wait
echo "Terminating"
