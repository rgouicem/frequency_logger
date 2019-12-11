#!/usr/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys

_, input_dir, output_file = sys.argv

# Read min, max and base freq
with open(input_dir+'/base_freq', 'r') as fp:
    base_freq = int(fp.readlines()[0])
with open(input_dir+'/max_freq', 'r') as fp:
    max_freq = int(fp.readlines()[0])
with open(input_dir+'/min_freq', 'r') as fp:
    min_freq = int(fp.readlines()[0])

# Read and process log
df = pd.read_csv(input_dir+'/log', sep=';')
dropIndex = df[df["frequency"] > max_freq].index
df.drop(dropIndex, inplace=True)
df["time"] = df["time"].astype("datetime64[ns]")
df["time"] = df["time"] - df["time"][0]
df["time"] = df["time"] / np.timedelta64(1, "s")
# df["frequency"] = df["frequency"] / 1000
end_time = df['time'].values[-1]

# Plot
plt.plot("time", "frequency", data=df, marker='+')
plt.hlines(base_freq, 0, end_time, label='base', colors=['green'], linestyles='dashed')
plt.hlines(min_freq, 0, end_time, label='min', colors=['black'], linestyles='dashed')
plt.hlines(max_freq, 0, end_time, label='max', colors=['red'], linestyles='dashed')

plt.xlabel("Time (s)")
plt.ylabel("Frequency (kHz)")
plt.legend()
plt.savefig(output_file, bbox_inches="tight")
