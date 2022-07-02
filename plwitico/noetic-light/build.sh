#!/bin/bash
docker build -t ssilenzi/plwitico:noetic-light --build-arg GITHUB_TOKEN=$1 ${@:2} "$(dirname ""$0"")"
