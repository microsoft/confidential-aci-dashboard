#!/bin/bash

python3 server.py &

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
