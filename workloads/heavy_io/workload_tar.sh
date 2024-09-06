#!/bin/bash
# Sleep a random time between 0 and 1 seconds.
# We do this because this issue seems to have something to do with badly timed
# IO while another container is starting up, but the exact timing may be
# different on ACI vs locally, or even on different systems.
# Be careful not to invoke any executables we want to test later, like Python,
# before the sleep.
sleepTime=0.$((RANDOM%10))
echo sleeping for $sleepTime | tee /dev/kmsg
sleep $sleepTime
echo ------------- payload start python + taring --------------- | tee /dev/kmsg
python3 -m http.server "$PORT" --bind 0.0.0.0 &
cd /
while :; do
  tar -c {bin,etc,home,lib,opt,root,sbin,usr,var} > /dev/null
  status=$?
  if [ $status -ne 0 ]; then
    kill %1
    exit $status
  fi
done
