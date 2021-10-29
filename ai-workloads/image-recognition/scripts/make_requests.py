#! /usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2020 Intel Corporation
# Copyright(c) 2020 Intracom Telecom S.A.

import schedule
import json
import logging
import argparse
import pathos.pools as pp
import socket
import os
import time
import glob
import tensorflow as tf
import requests

logging.basicConfig()
_log = logging.getLogger('TfServingRequests')


class TfServingRequests():

    def __init__(self, args):
        self.args = args
        self.threads = int(args.threads)
        self.timeout = int(args.timeout)
        self.url = args.url
        self.batch_size = int(args.batch_size)

        self.verbose = args.verbose
        if self.verbose >= 3:
            _log.setLevel(logging.DEBUG)
        elif self.verbose == 2:
            _log.setLevel(logging.INFO)
        elif self.verbose == 1:
            _log.setLevel(logging.ERROR)
        else:
            _log.setLevel(logging.CRITICAL)

        self.p = pp.ProcessPool(int(self.threads))

        _URL = 'https://storage.googleapis.com/mledu-datasets/cats_and_dogs_filtered.zip'
        path_to_zip = tf.keras.utils.get_file('cats_and_dogs.zip', origin=_URL, extract=True)
        self.image_path = os.path.join(os.path.dirname(path_to_zip), 'cats_and_dogs_filtered')

        self.batch = self.setup_input_images(self.batch_size)
        self.data = json.dumps({
            "instances": self.batch
        })
        _log.debug("Initialization completed")

    def setup_input_images(self, batch_size=32):
        validation_dir = os.path.join(self.image_path, 'validation')

        IMG_SIZE = (160, 160)

        validation_dataset = tf.keras.utils.image_dataset_from_directory(validation_dir,
                                                                         shuffle=False,
                                                                         batch_size=batch_size,
                                                                         image_size=IMG_SIZE)

        AUTOTUNE = tf.data.AUTOTUNE
        validation_dataset = validation_dataset.prefetch(buffer_size=AUTOTUNE)

        val_batch = validation_dataset.take(1)

        for batch, label in val_batch.as_numpy_iterator():
            return batch.tolist()


    def make_request(self, image):
        headers = {"content-type": "application/json"}
        result = requests.post(self.url, data=self.data, headers=headers, timeout=self.timeout)

        return {'result': json.loads(result.text)}

    def perform_requests(self):
        result_list = []

        # Run in parallel
        result_list.extend(self.p.map(self.make_request, [i for i in range(self.threads)]))

        _log.debug(result_list)

    def run(self):
        schedule.every(self.timeout).seconds.do(self.perform_requests)
        while True:
            schedule.run_pending()
            time.sleep(1)

        self.p.close()


def parser():
    parser = argparse.ArgumentParser(prog='TfServingRequests')
    parser.add_argument('-t', '--threads', dest="threads", default='8',
                        help='Tf parallel request threads (default: 8)')
    parser.add_argument('-b', '--batch-size', dest="batch_size", default='32',
                        help='Tf batch size (default: 32)')
    parser.add_argument('-u', '--url', dest="url", default="http://localhost:8501/v1/models/mobile_net_cats:predict",
                        help='Tf serving url (default: http://localhost:8501/v1/models/mobile_net_cats:predict)')
    parser.add_argument('-T', '--timeout', action='store', default=5, help='The update interval in seconds (default 5)')
    parser.add_argument(
        '-v',
        '--verbose',
        action='count',
        default=2,
        help='Set output verbosity (default: -vv = INFO)')
    return parser.parse_args()


def main():
    args = parser()
    dte = TfServingRequests(args)
    dte.run()


if __name__ == '__main__':
    main()
