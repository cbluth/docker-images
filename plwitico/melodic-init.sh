#!/bin/bash
git config --global user.email 's.silenzi1@gmail.com' && \
git config --global user.name 'Simone Silenzi' && \
git config --global url.https://aaaaaaaa@github.com/.insteadOf https://github.com/ && \
git clone --branch ${ROS_DISTRO}-devel --recurse-submodules https://github.com/CentroEPiaggio/planning-with-tight-constraints.git . && \
wstool update -t src && \
catkin config --extend /opt/ros/$ROS_DISTRO --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && \
( \
    echo ''; \
    echo '# source project'; \
    echo 'source /workspace/planning-with-tight-constraints/devel/setup.bash'; \
    echo ''; \
    echo '# ccache'; \
    echo 'export PATH="/usr/lib/ccache:${PATH}"'; \
) >> ~/.bashrc && \
source ~/.bashrc && \
catkin build planning_with_tight_constraints

