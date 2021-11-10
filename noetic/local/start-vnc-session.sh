#!/bin/bash
( kill -9 `pgrep x11vnc`; kill -9 `pgrep lxqt`; kill -9 `pgrep dbus`; kill -9 `pgrep xfwm4`; \
kill -9 `pgrep pcmanfm`; kill -9 `pgrep python3`; sudo kill -9 `pgrep X` ) > /dev/null 2>&1
sudo rm -f /tmp/.X1-lock
nohup sudo X ${DISPLAY} -config /etc/X11/xorg.conf > /dev/null 2>&1 &
nohup startlxqt > /dev/null 2>&1 &
nohup x11vnc -localhost -display ${DISPLAY} -N -forever -shared -bg > /dev/null 2>&1
nohup /opt/novnc/utils/novnc_proxy --web /opt/novnc --vnc localhost:5901 --listen 6080 > /dev/null 2>&1 &
