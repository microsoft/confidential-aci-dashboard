#!/usr/bin/env bash

# Sleep a random time between 0 and 1 seconds.
# We do this because this issue seems to have something to do with badly timed
# IO while another container is starting up, but the exact timing may be
# different on ACI vs locally, or even on different systems.
# Be careful not to invoke any executables we want to test later, like Python,
# before the sleep.
sleepTime=0.$((RANDOM%10))
echo sleeping for $sleepTime | tee /dev/kmsg
sleep $sleepTime

python3 server.py &

echo ------------- payload start fio --------------- | tee /dev/kmsg

while :; do
  fio  --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --bs=64k --iodepth=64 --readwrite=randrw --size=500M --loop=1000
  status=$?
  if [ $status -ne 0 ]; then
    kill %1
    exit $status
  fi
done
