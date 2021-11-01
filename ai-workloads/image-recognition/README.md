# Draft version

Exec into the container:
``` docker exec -it tf-serving-client /bin/bash ```

and install some rrequirements:
```
pip3 install pathos
pip3 install schedule
pip3 install --upgrade tensorflow
```

Then make requests by running:
```
cd scripts/
python3 make_requests.py -vvv -t 8 -b 32 -T 60
``` 
