#!/bin/bash

# A persistant python3 server to respond to our liveness probes
python3 -m http.server "$PORT" --bind 0.0.0.0 &

echo ------------- payload start taring --------------- | tee /dev/kmsg

cd /
while :; do
  tar -c {bin,etc,home,lib,opt,root,sbin,usr,var} > /dev/null
  status=$?
  if [ $status -ne 0 ]; then
    kill %1
    exit $status
  fi
done
