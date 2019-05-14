#!/bin/bash -e
echo "jupyter rebuild"
docker image rm 127.0.0.1:5000/openstudio-jupyter -f || true
docker build . -t="127.0.0.1:5000/openstudio-jupyter"
docker push 127.0.0.1:5000/openstudio-jupyter
echo 'jupyter rebuilt and pushed to registry'

