#!/bin/bash

# #January
# for i in $(seq 27 31)
# do
#     python3 prom-backup-copy.py -o /data/gcp/raw_metrics_60s/ -et $i-01-2024
#     # echo $i-02-2024
# done

# February
for i in $(seq 16 21)
do
    python3 prom-backup-df.py -o /data/gcp/raw_metrics_df_60s/ -et $i-02-2024
    # echo $i-02-2024
done
