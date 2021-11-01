#! /usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2020 Intel Corporation
# Copyright(c) 2020 Intracom Telecom S.A.

import schedule
import logging
import pathos.pools as pp
import time

import requests
import numpy as np
import base64
import json
import classes
import datetime
import argparse

logging.basicConfig()
_log = logging.getLogger('ServingRequests')


class TfServingRequests():

    def __init__(self, args):
        self.args = args
        self.threads = int(args.threads)
        self.input_images = args.images_list
        self.timeout = int(args.timeout)
        self.batch_size = int(args.batch_size)
        self.request_format = args.request_format
        self.output_name = args.output_name
        self.input_name = args.input_name
        self.model_name = args.model_name

        self.address = "{}/v1/models/{}:predict".format(
            args.rest_url, self.model_name)

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

        with open(self.input_images) as f:
            self.lines = f.readlines()
        while self.batch_size > len(self.lines):
            self.lines += self.lines

        _log.debug("Initialization completed")

    def create_request(self, image_data, request_format):
        signature = "serving_default"
        instances = []
        if request_format == "row_name":
            for image in image_data:
                jpeg_bytes = base64.b64encode(image).decode('utf-8')
                instances.append({self.input_name: {"b64": jpeg_bytes}})
        else:
            for image in image_data:
                jpeg_bytes = base64.b64encode(image).decode('utf-8')
                instances.append({"b64": jpeg_bytes})
        if request_format == "row_name":
            data_obj = {"signature_name": signature, "instances": instances}
        elif request_format == "row_noname":
            data_obj = {"signature_name": signature, "instances": instances}
        elif request_format == "column_name":
            data_obj = {"signature_name": signature, 'inputs': {self.input_name: instances}}
        elif request_format == "column_noname":
            data_obj = {"signature_name": signature, 'inputs': instances}
        else:
            print("invalid request format defined")
            exit(1)
        data_json = json.dumps(data_obj)
        return data_json

    def make_request(self, thread):
        count = 0
        matched = 0
        processing_times = np.zeros((0), int)

        batch_i = 0
        image_data = []
        labels = []
        session = requests.Session()
        for line in self.lines:
            batch_i += 1
            path, label = line.strip().split(" ")
            with open(path, 'rb') as f:
                image_data.append(f.read())
            labels.append(label)
            if batch_i < self.batch_size:
                continue
            # Compose a JSON Predict request (send JPEG image in base64).
            predict_request = self.create_request(image_data, self.request_format)
            start_time = datetime.datetime.now()
            result = session.post(self.address, data=predict_request)
            end_time = datetime.datetime.now()
            try:
                result_dict = json.loads(result.text)
            except ValueError:
                print("The server response is not json format: {}", format(result.text))
                exit(1)
            if "error" in result_dict:
                print('Server returned error: {}'.format(result_dict))
                exit(1)

            if "outputs" in result_dict:  # is column format
                keyname = "outputs"
                if type(result_dict[keyname]) is dict:
                    if self.output_name not in result_dict[keyname]:
                        print("Invalid output name", self.output_name)
                        print("Available outputs:")
                        for Y in result_dict[keyname]:
                            print(Y)
                        exit(1)
                    output = result_dict[keyname][self.output_name]
                else:
                    output = result_dict[keyname]
            elif "predictions" in result_dict:  # is row format
                keyname = "predictions"
                if type(result_dict[keyname][0]) is dict:  # are multiple outputs
                    output = []
                    for row in result_dict[keyname]:  # iterate over all results in the batch
                        output.append(row[self.output_name])
                else:
                    output = result_dict[keyname]
            else:
                print("Missing required response in {}".format(result_dict))
                exit(1)
            duration = (end_time - start_time).total_seconds() * 1000
            processing_times = np.append(processing_times, np.array([int(duration)]))
            # for object classification models show imagenet class
            print('Batch: {}; Processing time: {:.2f} ms; speed {:.2f} fps'.format(
                count // self.batch_size, round(duration, 2), round(1000 / duration, 2)))

            nu = np.array(output)  # numpy array with inference results
            print("output shape: {}".format(nu.shape))
            for i in range(nu.shape[0]):
                single_result = nu[[i], ...]
                offset = 0
                if nu.shape[1] == 1001:
                    offset = 1
                ma = np.argmax(single_result) - offset
                mark_message = ""
                if int(labels[i]) == ma:
                    matched += 1
                    mark_message = "; Correct match."
                else:
                    mark_message = "; Incorrect match. Should be {} {}".format(
                        label, classes.imagenet_classes[int(label)])
                count += 1
                print("\t", count, classes.imagenet_classes[ma], ma, mark_message)
            image_data = []
            labels = []
            batch_i = 0

        latency = np.average(processing_times)
        accuracy = matched / count

        print("Overall accuracy=", accuracy * 100, "%")
        print("Average latency=", latency, "ms")

    def perform_requests(self):
        result_list = []

        # Run in parallel
        result_list.extend(self.p.map(self.make_request, [i for i in range(self.threads)]))

        _log.debug(result_list)

    def run(self):
        schedule.every(self.timeout).seconds.do(self.perform_requests)
        while True:
            print('Start processing:')
            print('\tModel name: {}'.format(self.model_name))
            print('\tImages list file: {}'.format(self.input_images))
            schedule.run_pending()
            time.sleep(1)

        self.p.close()


def parser():
    parser = argparse.ArgumentParser(prog='ServingRequests',
                        description='Sends requests via TensorFlow Serving RESTful API using images in binary format.')
    parser.add_argument('--images_list', required=False, default='input_images.txt',
                        help='path to a file with a list of labeled images', dest='images_list')
    parser.add_argument('--threads', required=False, default='8',
                        help='Specify the number of parallel request threads (default: 8)', dest='threads')
    parser.add_argument('--rest_url', required=False, default='http://localhost:8000',
                        help='Specify url to REST API service. default: http://localhost:8000', dest='rest_url')
    parser.add_argument('--input_name', required=False, default='image_bytes',
                        help='Specify input tensor name. default: image_bytes', dest='input_name')
    parser.add_argument('--output_name', required=False, default='probabilities',
                        help='Specify output name. default: probabilities', dest='output_name')
    parser.add_argument('--model_name', default='resnet',
                        help='Define model name, must be same as is in service. default: resnet',
                        dest='model_name')
    parser.add_argument('--request_format', default='row_noname',
                        help='Request format according to TF Serving API: row_noname,row_name,column_noname,column_name',
                        choices=["row_noname", "row_name", "column_noname", "column_name"], dest='request_format')
    # If input numpy file has too few frames according to the value of iterations and the batch size, it will be
    # duplicated to match requested number of frames
    parser.add_argument('--batchsize', default=1, help='Number of images in a single request. default: 1',
                        dest='batch_size')
    parser.add_argument('--timeout', action='store', default=1, help='The timeout interval in seconds (default 1)')
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
