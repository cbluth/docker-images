#!/bin/bash
git config --global user.email 'your@email.com' && \
git config --global user.name 'Your Name' && \
git config --global url.https://aaaaaaaa@github.com/.insteadOf https://github.com/ && \
git clone --branch ${ROS_DISTRO}-devel --recurse-submodules https://github.com/CentroEPiaggio/planning-with-tight-constraints.git . && \
wstool update -t src && \
catkin config --extend /opt/ros/$ROS_DISTRO --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && \
( \
    echo ''; \
    echo '# source project'; \
    echo 'SETUP_SCRIPT=/workspaces/planning-with-tight-constraints/devel/setup.bash'; \
    echo 'if [ -f $SETUP_SCRIPT ]; then source $SETUP_SCRIPT; fi'; \
) >> ~/.bashrc && \
source ~/.bashrc && \
catkin build planning_with_tight_constraints && ./.compile_commands.sh

