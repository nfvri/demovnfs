FROM tensorflow/serving:2.10.1

ENV MODEL_NAME=mobile_net_cats
COPY requirements.txt /

RUN apt-get update && \
    apt-get install -y python3 python3-dev python3-pip && \
    apt -y clean && \
    pip3 install --upgrade pip && \
    pip3 install -r /requirements.txt

COPY imagenet_resnet_v2_50 /models/imagenet_resnet_v2_50
COPY mobile_net_cats /models/mobile_net_cats

