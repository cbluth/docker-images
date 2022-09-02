#!/bin/bash
docker build -t ssilenzi/noetic:light $@ "$(dirname ""$0"")"
