#!/bin/bash
docker build -t ssilenzi/plwitico:melodic-local --build-arg GITHUB_TOKEN=$1 "$(dirname ""$0"")"
