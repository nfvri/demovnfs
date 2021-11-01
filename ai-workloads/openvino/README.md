# Run OpenVino Model Server

Source code at: https://github.com/openvinotoolkit/model_server, 
https://github.com/openvinotoolkit/model_server/blob/main/docs/binary_input.md

The model has been downloaded from the Google Storage using the command:
```
gsutil cp gs://ovms-public-eu/resnet50-binary resnet50-binary
```
and it is stored under the folder resnet50-binary.

Run OpenVino Model Server to serve model resnet:
```
docker-compose -f docker-compose.yaml up -d
```

Run the client on the same or different server to make requests.

Download the requirements:
```
pip install -r requirements.txt
```

And run the make_requests.py script with the desired arguments:
```
python3 ./make_requests.py --rest_url http://clx2:8088 --model_name resnet --input_name 0 --output_name 1463 --images input_images.txt --batchsize 2 --threads 4
```


