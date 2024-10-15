#!/bin/bash

python3 server.py &

echo ------------- payload start sysbench --------------- | tee /dev/kmsg

while :; do
  sysbench --threads=$(nproc) --time=10000 cpu run
  status=$?
  if [ $status -ne 0 ]; then
    kill %1
    exit $status
  fi
done
kill %1
