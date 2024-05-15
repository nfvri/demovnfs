import requests as r
import argparse
import os
import datetime
from prometheus_api_client import PrometheusConnect


def get_metrics(filename):
    with open(filename, "r+") as file:
        while True:
            line = file.readline().strip()
            if not line:
                break
            if line.startswith("#"):
                continue
            yield line

def get_last_day_metrics(prom, base_path, metrics_file, endtime, step):
    '''
    Fetch metrics ranging from `endtime` variable up to 24h back with `step` seconds query resolution step
    '''
    if endtime == "now":
        endtime = datetime.datetime.now()
    else:
        endtime = datetime.datetime.strptime(endtime, '%d-%m-%Y')

    timedelta = datetime.timedelta(hours=24)
    starttime = endtime - timedelta

    if not os.path.isdir(base_path):
            os.makedirs(base_path)

    path = base_path + f"{starttime.date().strftime('%d-%m-%Y')}/"
    if not os.path.isdir(path):
        os.mkdir(path)

    for metric in get_metrics(metrics_file):
        metric_dir_path = path + f"{metric}/"
        if not os.path.isdir(metric_dir_path):
            os.mkdir(metric_dir_path)

        # path = path + f"/{endtime.date().strftime('%d-%m-%Y')}"
        # if not os.path.isdir(path):
        #     os.mkdir(path)
        
        out_filename = metric_dir_path + f'raw_results.txt'
        raw_metrics = open(out_filename, "w")

        result = prom.custom_query_range(
            metric, start_time=starttime, end_time=endtime, step=step
        )

        print(f" writing {out_filename}")
        for res in result:
            raw_metrics.write(f"{str(res)}\n")

        raw_metrics.close()


def main():
    parser = argparse.ArgumentParser(
        prog='Prom-backup',
        description='Get raw metrics from Prometheus every day at 00:00:00'
    )
    
    parser.add_argument(
        '-s', '--server', default='http://8.34.211.21:30090'
    )
    parser.add_argument(
        '-f', '--filename', default="/data/kchondr/arcadia/prom-backup/metrics.txt"
    )
    parser.add_argument(
        '-o', '--output', default="/data/kchondr/arcadia/prom-backup/gcp/raw_metrics/"
    )
    parser.add_argument(
        '-et', '--endtime',
        default="now",
        help="formart date as follows: day-month-year e.g 30-10-2023"
    )
    parser.add_argument('-st', '--step', default=60)

    args = parser.parse_args()

    prom = PrometheusConnect(args.server, disable_ssl=True)

    get_last_day_metrics(
        prom,
        base_path=args.output,
        metrics_file=args.filename,
        endtime=args.endtime,
        step=args.step
    )


if __name__ == '__main__':
    main()