#!/bin/bash
# A "baseline" case running only the Python server

python3 server.py &
SERVER_PID=$!

echo ------------- payload does nothing --------------- | tee /dev/kmsg

sleep infinity
