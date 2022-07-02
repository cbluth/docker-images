#!/bin/bash
docker build -t ssilenzi/plwitico:melodic-gitpod --build-arg GITHUB_TOKEN=$1 ${@:2} "$(dirname ""$0"")"
