FROM ssilenzi/melodic:gitpod
LABEL org.opencontainers.image.title="Planning with tight contraints"
LABEL org.opencontainers.image.description="Python / C++ implementation of framework of manipulation planning with tight environment constraints."
LABEL org.opencontainers.image.source="https://github.com/CentroEPiaggio/planning-with-tight-constraints"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"

USER gitpod
WORKDIR /workspace

# Install project dependencies
ARG GITHUB_TOKEN
RUN git config --global url."https://$GITHUB_TOKEN:@github.com/".insteadOf "https://github.com/" && \
    git clone --branch ${ROS_DISTRO}-devel --depth 1 https://github.com/CentroEPiaggio/planning-with-tight-constraints.git && \
    git config --global --remove-section url."https://$GITHUB_TOKEN:@github.com/" && \
    cd planning-with-tight-constraints/ && \
    sudo apt-get update && \
    rosdep update && \
    wstool update -t src && \
    rosdep install --from-paths src --ignore-src --rosdistro melodic -r -y && \
    cd .. && rm -Rf planning-with-tight-constraints/ && \
    sudo apt-get clean && \
    sudo rm -Rf /var/lib/apt/lists/*

# Start the container
CMD ["bash"]
