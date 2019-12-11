#! /bin/bash

[ $# -ne 1 ] && { echo "Usage: log_freq.sh cpu"; exit 255; }
[ $EUID -ne 0 ] && { echo "Run this with more privileges (root or sudo)"; exit 254; }

# Usage: readfreq cpu
function readfreq {
    ### MSR definitions
    IA32_MPERF=0xe7
    IA32_APERF=0xe8

    d=$(date -Ins)
    m=$(rdmsr -p$1 $IA32_MPERF -d)
    a=$(rdmsr -p$1 $IA32_APERF -d)
    (( dm = m - lm ))
    (( da = a - la ))
    (( freq = base_mhz * da / dm ))
    lm=$m
    la=$a
    echo "$d;$freq"
}

# Get base freq
base_mhz=$(awk '
	/^model name.*GHz$/ { sub(/GHz/, "", $NF); printf("%d", $NF * 1000); exit; }
	/^model name.*MHz/ { sub(/MHz/, "", $NF); printf("%d", $NF); exit; }' /proc/cpuinfo)
if (( base_mhz == 0 )); then
	echo "ERROR: Can't find base MHz from /proc/cpuinfo model name. Exiting."
	# if this happens, switch to MSR_PLATFORM_INFO or CPUID
	exit 1
fi

echo "time;frequency"
while : ; do
    readfreq $1
done
