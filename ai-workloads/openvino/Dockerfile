FROM openvino/model_server:2021.4.2

COPY resnet50-binary /resnet50-binary
COPY images /images
COPY classes.py /
COPY make_requests.py /
COPY requirements.txt /

USER root

RUN apt-get update && apt-get install -y python3 python3-dev python3-pip && apt -y clean
RUN pip3 install -r /requirements.txt

USER ovms