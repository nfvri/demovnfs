# Prometheus metrics Backup
This is a collection of scripts that were used during the two testing phases pf the arcadia project and performed daily backups 
of prometheus metrics.


In order to perform a backup prcedure you need to provide a few pieces of information to the scripts.
- input file: Input file has the metrics (expressed in PromQL) that will be collected
- promehteus server ip
- output file path:
    absolut path of the output files
- endtime (day-month-year e.g 30-10-2023):
    Provided with an endtime, the script fetches data starting from endtime-24h to endtime.
    ```
    Example: endtime = 00.00.00 16/05/2024
            the script will fetch timeseries data starting from 00.00.00 15/05/2024 to 00.00.00 16/05/2024
    ```
- step: (in secsonds):
    Dictates the frequency of datapoints within the resulting timeseries.
    ```
    Example: steps = 60sec.
    If we were to fetch data in a 10 minute window 00.00.00 16/05/2024 to 00.10.00 16/05/2024, the script would fetch 10 data points.
    
    timestamp,              value
    00.00.00 16/05/2024     20
    00.01.00 16/05/2024     25
    00.02.00 16/05/2024     33
    00.03.00 16/05/2024     44
    ...
    00.09.00 16/05/2024     34
    00.10.00 16/05/2024     29```

## Usage
```
$ python prom-bakup.py -i

usage: Prom-backup [-h] [-s SERVER] [-f FILENAME] [-o OUTPUT] [-et ENDTIME] [-st STEP]

Get raw metrics from Prometheus every day at 00:00:00

options:
  -h, --help            show this help message and exit
  -s SERVER, --server SERVER
  -f FILENAME, --filename FILENAME
  -o OUTPUT, --output OUTPUT
  -et ENDTIME, --endtime ENDTIME
                        formart date as follows: day-month-year e.g 30-10-2023
  -st STEP, --step STEP
```
