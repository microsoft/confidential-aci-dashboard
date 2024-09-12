#!/bin/bash

python3 server.py &

echo ------------- payload start sysbench --------------- | tee /dev/kmsg

sysbench --threads=$(nproc) --time=1000 cpu run
kill %1
