#!/usr/bin/env bash
if [ $# -ne 2 ]
then
  echo "No arguments supplied"
  exit 1
else
  docker run -it --rm --shm-size=2g -p 127.0.0.1:$2:6080 --name $1 ssilenzi/recordings:latest
  exit $?
fi

