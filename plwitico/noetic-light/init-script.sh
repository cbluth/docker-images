#!/bin/bash

CONTAINER_ALREADY_STARTED="${HOME}/.container_already_started_placeholder"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    git config --global user.email "${EMAIL}" && \
    git config --global user.name "${NAME}" && \
    git config --global url.https://${GITHUB_TOKEN}@github.com/.insteadOf https://github.com/ && \
    git clone --branch ${ROS_DISTRO}-devel --recurse-submodules https://github.com/CentroEPiaggio/planning-with-tight-constraints.git . && \
    catkin config --extend /opt/ros/${ROS_DISTRO} --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && \
    ( \
        echo ''; \
        echo '# source project'; \
        echo 'SETUP_SCRIPT=/workspaces/planning-with-tight-constraints/devel/setup.bash'; \
        echo 'if [ -f $SETUP_SCRIPT ]; then source $SETUP_SCRIPT; fi'; \
    ) >> ~/.bashrc && \
    source ~/.bashrc && \
    catkin build planning_with_tight_constraints && /workspaces/planning-with-tight-constraints/scripts/compile_commands.sh
fi

$@
