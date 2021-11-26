#!/bin/bash

# Install x-related to compile x11vnc from source code.
apt-get update 
apt-get install -y libxtst-dev libssl1.0-dev libjpeg-dev libtcl8.6 libtk8.6 \
  libvncclient1 libvncserver1 tcl tcl8.6 tk tk8.6 zlib1g-dev x11vnc \
  x11vnc-data
apt-get purge -y x11vnc x11vnc-data

# Grep source code.
wget http://x11vnc.sourceforge.net/dev/x11vnc-0.9.14-dev.tar.gz
gzip -dc x11vnc-0.9.14-dev.tar.gz | tar -xvf -
cd x11vnc-0.9.14
./configure --prefix=/usr/local CFLAGS='-g -O2 -fno-stack-protector -Wall'

# Make and Make install.
make
make install

# Clean.
cd ..
apt-get install -y --autoremove --purge libssl-dev libtcl8.6 libtk8.6 \
  libvncclient1 libvncserver1 tcl tcl8.6 tk tk8.6
rm -Rf ./x11vnc*
