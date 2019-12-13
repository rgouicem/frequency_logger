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

# Read and process log (prune out of range points)
df = pd.read_csv(input_dir+'/log', sep=';')
df.drop(df.index[-1], inplace=True) # drop last cause it might be incomplete
dropIndex = df[df["frequency"] > max_freq].index
df.drop(dropIndex, inplace=True)
dropIndex = df[df["frequency"] < min_freq].index
df.drop(dropIndex, inplace=True)

# move start time to 0
# df["time"] = df["time"].astype("datetime64[ns]")
start_time = min(df['time'].values)
df["time"] -= start_time

# convert time to seconds and frequency to MHz
# df["time"] /= np.timedelta64(1, "s")
df["time"] /= 1000000000
df["frequency"] = df["frequency"] / 1000

end_time = max(df['time'].values)

# Read events file
try:
    events = pd.read_csv(input_dir+'/events', sep=';', header=None,
                         names=['time', 'label', 'color'])
    # events['time'] = events['time'].astype("datetime64[ns]")
    events['time'] -= start_time
    events['time'] /= 1000000000
    # events['time'] /= np.timedelta64(1, "s")
except:
    pass

# Plot
plt.figure(figsize=(15, 10))
plt.plot("time", "frequency", data=df # , marker='+'
)
plt.hlines(base_freq / 1000, 0, end_time,
           label='base', colors='green', linestyles='dashed')
plt.hlines(min_freq / 1000, 0, end_time,
           label='min', colors='black',  linestyles='dashed')
plt.hlines(max_freq / 1000, 0, end_time,
           label='max', colors='red', linestyles='dashed')

try:
    for e in events.itertuples(index=False):
        plt.vlines(e.time,
                   min_freq / 1000 - 100, max_freq / 1000 + 100,
                   colors=e.color,
                   label=e.label,
                   linestyles='dotted')
except:
    pass

plt.xlabel("Time (s)")
plt.ylabel("Frequency (MHz)")
plt.legend()
plt.savefig(output_file, bbox_inches="tight")
