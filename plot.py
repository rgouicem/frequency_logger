#!/usr/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys
import plotly.graph_objects as go
import plotly.express as px

_, input_dir, output_file = sys.argv

# Frequency ratio: MHz: 1000, GHz: 1000000
freq_ratio = 1000000

plt.rcParams.update({'font.size':'30'})

# Read min, max and base freq
with open(input_dir+'/base_freq', 'r') as fp:
    base_freq = int(fp.readlines()[0])
with open(input_dir+'/tsc_khz', 'r') as fp:
    tsc_khz = int(fp.readlines()[0])
with open(input_dir+'/max_freq', 'r') as fp:
    max_freq = int(fp.readlines()[0])
with open(input_dir+'/min_freq', 'r') as fp:
    min_freq = int(fp.readlines()[0])

# Read log
# We drop the first record because it will be 0 GHz
# We drop the last record because it might be incomplete
# We drop records exceeding 7Ghz because it makes no sense on any CPU
df = pd.read_csv(input_dir+'/log', sep=';')
df.drop(df.index[0], inplace=True)
df.drop(df.index[-1], inplace=True)
dropIndex = df[df["frequency"] > 7000000].index
df.drop(dropIndex, inplace=True)

# move start time to 0
start_time = min(df['tsc'].values)
df["tsc"] -= start_time

# convert time to seconds (with tsc if available) and frequency to GHz
if tsc_khz != 0:
    df["time"] = df["tsc"] / (1000 * tsc_khz)
else:
    df["time"] = df["tsc"] / 1000000000
df["frequency"] = df["frequency"] / freq_ratio

# Compute the median on 3 point windows to remove spikes due to bad measures
median_freq = [ df.iloc[0]['frequency'] ]
for i in range(1,len(df)-1):
    median_freq.append(np.median(df.iloc[i-1:i+2]["frequency"]))

median_freq.append(df.iloc[-1]['frequency'])
df['frequency_median'] = median_freq
end_time = max(df['time'].values)

# Compute stats on deltas between samples
deltas = df["time"].values[1:] - df["time"].values[:-1]

# Read events file
try:
    events = pd.read_csv(input_dir+'/events', sep=';', header=None,
                         names=['time', 'label', 'color'])
    events['time'] -= start_time
    if tsc_khz != 0:
        events["time"] /= (1000 * tsc_khz)
    else:
        events['time'] /= 1000000000
except:
    pass

# Plot
# plt.figure(figsize=(15, 10))
#fig = go.Figure()
fig, ax = plt.subplots(figsize=(15, 10), dpi=300)

# plt.plot("time", "frequency", data=df, marker='+')
# fig.add_trace(go.Scatter(x=df['time'], y=df['frequency'],
#                          name='Frequency', mode='lines+markers',
#                          line=dict(color='blue')# , showlegend=True
# ))
plt.plot("time", "frequency_median", data=df, marker='+')
# fig.add_trace(go.Scatter(x=df['time'], y=df['frequency_median'],
#                          name='Frequency_median', mode='lines+markers',
#                          line=dict(color='red')# , showlegend=True
# ))

plt.hlines(base_freq / freq_ratio, 0, end_time,
           label='base', colors='green', linestyles='dashed')

# fig.add_shape(type='line', x0=0, x1=end_time, y0=base_freq / freq_ratio, y1=base_freq / freq_ratio,
#               name='Base', line=dict(dash='dash', color='green'))

plt.hlines(min_freq / freq_ratio, 0, end_time,
           label='min', colors='black',  linestyles='dashed')
# fig.add_shape(type='line', x0=0, x1=end_time, y0=min_freq / freq_ratio, y1=min_freq / freq_ratio,
#               name='Minimum', line=dict(dash='dash', color='black'))

plt.hlines(max_freq / freq_ratio, 0, end_time,
           label='max', colors='red', linestyles='dashed')
# fig.add_shape(type='line', x0=0, x1=end_time, y0=max_freq / freq_ratio, y1=max_freq / freq_ratio,
#               name='Maximum', line=dict(dash='dash', color='red'))

try:
    for e in events.itertuples(index=False):
        # ax.axvline(x = e.time, color = e.color, label = e.label, linstyle='dotted')
        plt.vlines(e.time,
                   min_freq / freq_ratio, max_freq / freq_ratio,
                   colors=e.color,
                   label=e.label,
                   linestyles='dashdot')
        # fig.add_shape(type='line', x0=e.time, x1=e.time, y0=min_freq / freq_ratio, y1=max_freq / freq_ratio,
        #               name=e.label, line=dict(dash='dash', color=e.color))
except:
    pass

plt.xlabel("Time (s)")
plt.ylabel("Frequency (GHz)")
# plt.title("Mean delta: {:2.6f}s".format(deltas.mean()))
plt.rcParams.update({'font.size':'15'})
# plt.legend()
plt.savefig(output_file, bbox_inches="tight")

# fig.update_layout(
#     title="Mean delta: {:2.6f}s".format(deltas.mean()),
#     xaxis_title="Time (s)",
#     yaxis_title="Frequency (GHz)",
#     font=dict(size=15)
# )
# fig.write_html(output_file[:-3]+'html')
