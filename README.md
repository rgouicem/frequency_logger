This tool is highly inspired from Brendan Greg's `msr-cloud-tools` (https://github.com/brendangregg/msr-cloud-tools).

# Usage
Monitor the frequency of `cpu` and store it in `freq.log`:
```
   ./log_freq.sh cpu > freq.log
```

Plot the frequency over time (generates `freq.pdf` file):
```
   ./plot.py freq.log freq.pdf
```
