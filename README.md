This tool is highly inspired from Brendan Greg's `msr-cloud-tools` (https://github.com/brendangregg/msr-cloud-tools).

# Usage
Monitor the frequency of `cpu` each `interval` second (optionnal, defaults to 0.1s) and store results in `output_dir`, with some metadata:
```
   ./log_freq.sh cpu output_dir [interval]
```

Plot the frequency over time (`output` should be a `.pdf`, `input_dir` is the `output_dir` from the previous command):
```
   ./plot.py input_dir output
```

You can see the `test_apps/test_loop.sh` script for an exemple of how to use this tool.
