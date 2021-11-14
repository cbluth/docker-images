FROM ssilenzi/noetic:light
LABEL org.opencontainers.image.title="Planning with tight contraints"
LABEL org.opencontainers.image.description="Python / C++ implementation of framework of manipulation planning with tight environment constraints."
LABEL org.opencontainers.image.source="https://github.com/CentroEPiaggio/planning-with-tight-constraints"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"

USER ubuntu
WORKDIR /workspace

# Install project dependencies
ARG GITHUB_TOKEN
ENV PATH="/usr/lib/ccache:${PATH}"
RUN wget -O gurobi.tar.gz https://packages.gurobi.com/9.5/gurobi9.5.0_linux64.tar.gz && \
    sudo mv gurobi.tar.gz /opt/ && \
    sudo chown root:root /opt/gurobi.tar.gz && \
    sudo tar -C /opt -xzvf /opt/gurobi.tar.gz && \
    sudo rm /opt/gurobi.tar.gz && \
    ( \
    echo ""; \
    echo "# gurobi"; \
    echo "export GUROBI_HOME=\"/opt/gurobi950/linux64\""; \
    echo "export PATH=\"\${PATH}:\${GUROBI_HOME}/bin\""; \
    echo "export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:\${GUROBI_HOME}/lib\"" \
    ) >> ~/.bashrc && \
    git config --global url."https://$GITHUB_TOKEN:@github.com/".insteadOf "https://github.com/" && \
    git clone --branch ${ROS_DISTRO}-devel --depth 1 --recurse-submodules https://github.com/CentroEPiaggio/planning-with-tight-constraints.git && \
    git config --global --remove-section url."https://$GITHUB_TOKEN:@github.com/" && \
    cd planning-with-tight-constraints/ && \
    sudo apt-get update && \
    rosdep update && \
    wstool update -t src && \
    echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections && \
    rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -r -y && \
    catkin config --extend /opt/ros/$ROS_DISTRO --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && \
    catkin build && \
    ccache -s && \
    cd .. && rm -Rf planning-with-tight-constraints/ && mkdir planning-with-tight-constraints/ && \
    sudo apt-get clean && \
    sudo rm -Rf /var/lib/apt/lists/*

# Start the container
WORKDIR /workspace/planning-with-tight-constraints
CMD ["bash"]
