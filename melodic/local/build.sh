#!/bin/bash
docker build -t ssilenzi/melodic:local $@ "$(dirname ""$0"")"
