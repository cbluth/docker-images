#!/bin/bash
docker build -t ssilenzi/plwitico:noetic-gitpod --build-arg GITHUB_TOKEN=$1 "$(dirname ""$0"")"
