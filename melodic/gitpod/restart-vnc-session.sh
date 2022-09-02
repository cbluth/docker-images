#!/bin/bash
nohup x11vnc -localhost -display ${DISPLAY} -N -forever -shared -bg > /dev/null 2>&1
