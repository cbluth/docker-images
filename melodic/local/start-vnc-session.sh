#!/bin/bash
( kill -9 `pgrep x11vnc`; kill -9 `pgrep xorg`; kill -9 `pgrep python3`; kill -9 `pgrep dbus`; \
  kill -9 `pgrep caja`; sudo kill -9 `pgrep X` ) > /dev/null 2>&1
sudo rm -f /tmp/.X1-lock
nohup sudo X ${DISPLAY} -config /etc/X11/xorg.conf > /dev/null 2>&1 &
nohup mate-session > /dev/null 2>&1 &
nohup mate-panel > /dev/null 2>&1 &
nohup x11vnc -localhost -display ${DISPLAY} -N -forever -shared -bg > /dev/null 2>&1
nohup /opt/novnc/utils/novnc_proxy --web /opt/novnc --vnc localhost:5900 --listen 6080 > /dev/null 2>&1 &
