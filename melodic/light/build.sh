#!/bin/bash
docker build -t ssilenzi/melodic:light $@ "$(dirname ""$0"")"
