#!/bin/bash
cd /workspace && nohup markserv --browser false -a localhost -p 8080 > /dev/null 2>&1 &
