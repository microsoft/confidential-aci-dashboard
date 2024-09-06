#!/usr/bin/env bash

# Sleep a random time between 0 and 1.5 seconds.
# We do this because this issue seems to have something to do with badly timed
# IO while another container is starting up, but the exact timing may be
# different on ACI vs locally, or even on different systems.
sleepTime=`python3 -c 'import random; print(random.random()*1.5*100//1/100)'`
echo sleep $sleepTime
echo sleep $sleepTime > /dev/kmsg
sleep $sleepTime
python3 -m http.server "$PORT" --bind 0.0.0.0 &
echo ------------- payload start taring ---------------
echo ------------- payload start taring --------------- > /dev/kmsg
cd /
while :; do
  tar -c {bin,etc,home,lib,opt,root,sbin,usr,var} > /dev/null
  status=$?
  if [ $status -ne 0 ]; then
    kill %1
    exit $status
  fi
done
