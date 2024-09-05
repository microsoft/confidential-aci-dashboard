#!/usr/bin/env bash

python3 -m http.server "$PORT" --bind 0.0.0.0 &
sleepTime=`python3 -c 'import random; print(random.random()*1.5*100//1/100)'`
echo sleep $sleepTime
echo sleep $sleepTime > /dev/kmsg
sleep $sleepTime
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
