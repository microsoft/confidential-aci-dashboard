#!/bin/bash

# A persistant python3 server to respond to our liveness probes
python3 -m http.server "$PORT" --bind 0.0.0.0 &

echo ------------- payload start sysbench --------------- | tee /dev/kmsg

sysbench --threads=$(nproc) --time=1000 cpu run
kill %1
