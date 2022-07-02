#!/bin/bash
cd /workspace && nohup jupyter lab --ip=localhost --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' > /dev/null 2>&1 &
