#!/bin/bash
docker build -t ssilenzi/plwitico:noetic-gitpod --build-arg GITHUB_TOKEN=$1 ${@:2} "$(dirname ""$0"")"
