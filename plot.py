#!/usr/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys

_, input_dir, output_file = sys.argv

# Frequency ratio: MHz: 1000, GHz: 1000000
freq_ratio = 1000000

plt.rcParams.update({'font.size':'30'})

# Read min, max and base freq
with open(input_dir+'/base_freq', 'r') as fp:
    base_freq = int(fp.readlines()[0])
with open(input_dir+'/max_freq', 'r') as fp:
    max_freq = int(fp.readlines()[0])
with open(input_dir+'/min_freq', 'r') as fp:
    min_freq = int(fp.readlines()[0])

# Read log
# We drop the last record because it might be incomplete
df = pd.read_csv(input_dir+'/log', sep=';')
df.drop(df.index[-1], inplace=True)

# move start time to 0
start_time = min(df['time'].values)
df["time"] -= start_time

# convert time to seconds and frequency to GHz
df["time"] /= 1000000000
df["frequency"] = df["frequency"] / freq_ratio

end_time = max(df['time'].values)

# Compute stats on deltas between samples
deltas = df["time"].values[1:] - df["time"].values[:-1]

# Read events file
try:
    events = pd.read_csv(input_dir+'/events', sep=';', header=None,
                         names=['time', 'label', 'color'])
    events['time'] -= start_time
    events['time'] /= 1000000000
except:
    pass

# Plot
plt.figure(figsize=(15, 10))
plt.plot("time", "frequency", data=df, marker='+')
plt.hlines(base_freq / freq_ratio, 0, end_time,
           label='base', colors='green', linestyles='dashed')
plt.hlines(min_freq / freq_ratio, 0, end_time,
           label='min', colors='black',  linestyles='dashed')
plt.hlines(max_freq / freq_ratio, 0, end_time,
           label='max', colors='red', linestyles='dashed')

try:
    for e in events.itertuples(index=False):
        plt.vlines(e.time,
                   min_freq / freq_ratio, max_freq / freq_ratio,
                   colors=e.color,
                   label=e.label,
                   linestyles='dotted')
except:
    pass

plt.xlabel("Time (s)")
plt.ylabel("Frequency (GHz)")
plt.title("Mean delta: {:2.6f}s".format(deltas.mean()))
plt.rcParams.update({'font.size':'15'})
plt.legend()
plt.savefig(output_file, bbox_inches="tight")
