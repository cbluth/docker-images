#!/bin/bash
docker build -t ssilenzi/plwitico:noetic-light --build-arg GITHUB_TOKEN=$1 "$(dirname ""$0"")"
