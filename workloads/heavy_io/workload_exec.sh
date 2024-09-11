#!/bin/bash

# A persistant python3 server to respond to our liveness probes
python3 -m http.server "$PORT" --bind 0.0.0.0 &

echo ------------- payload start ls loop --------------- | tee /dev/kmsg

while :; do
  ls loooooooooooooooooooooooooooooooooooooooonnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnggggggggggggggggggggg 2>/dev/null
  status=$?
  if [ $status -eq 139 ]; then # SEGV
    kill %1
    exit $status
  fi
done
