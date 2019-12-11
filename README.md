This tool is highly inspired from Brendan Greg's `msr-cloud-tools` (https://github.com/brendangregg/msr-cloud-tools).

# Usage
Monitor the frequency of `cpu` each `interval` second (default: 0.1s) and store it in `freq.log`:
```
   ./log_freq.sh cpu interval > freq.log
```

Plot the frequency over time (`output` should be a `.pdf`):
```
   ./plot.py input output
```
