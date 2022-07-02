FROM osrf/ros:noetic-desktop

LABEL org.opencontainers.image.title="ROS Noetic"
LABEL org.opencontainers.image.description="A full Ubuntu environment."
LABEL org.opencontainers.image.source="https://github.com/ssilenzi/docker-images"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"

ENV ROS_DISTRO=noetic

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install essentials
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y apt-utils software-properties-common apt-transport-https sudo psmisc lsb-release nano wget curl \
    gnupg build-essential gdb git cmake autoconf automake locales gdebi dos2unix bash-completion ssl-cert less zip unzip \
    ccache clang-format-10 gedit dbus-x11 nautilus x11-apps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# locales
RUN date && (echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections) && locale-gen en_US.UTF-8

# Install ROS
RUN apt-get update && \
    apt-get install -y python3-catkin-tools python3-rosdep \
    python3-rosinstall python3-rosinstall-generator python3-wstool && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt-get update && \
    apt-get install -y python3-autopep8 python3-dev mypy python3-mypy python3-pip python3-pycodestyle \
    python3-setuptools python3-virtualenv python3-wheel && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Smartgit
COPY smartgit /usr/bin/
RUN apt-get update && \
    wget -O smart.deb https://www.syntevo.com/downloads/smartgit/smartgit-21_2_2.deb && \
    gdebi -n smart.deb && \
    rm smart.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /usr/bin/smartgit && \
    dos2unix /usr/bin/smartgit

# Create ubuntu user
RUN useradd -l -u 1000 -G sudo -md /home/ubuntu -s /bin/bash ubuntu && \
    yes ubuntu | passwd ubuntu && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Switch to ubuntu user
USER ubuntu

# Setup env vars
ENV PATH="/usr/lib/ccache:/home/ubuntu/.local/bin:/usr/share/smartgit/bin:${PATH}"

# Install informative git for bash
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1
ENV GIT_PROMPT_ONLY_IN_REPO=1

# Switch back to root
USER root

# Set up ccache
RUN cp /usr/bin/ccache /usr/local/bin/ && \
    ln -s /usr/bin/ccache /usr/local/bin/gcc && \
    ln -s /usr/bin/ccache /usr/local/bin/g++ && \
    ln -s /usr/bin/ccache /usr/local/bin/cc  && \
    ln -s /usr/bin/ccache /usr/local/bin/c++

# XDG_RUNTIME_DIR
RUN mkdir /run/user/1000 && \
    chown -R ubuntu:ubuntu /run/user/1000 && \
    chmod -R 0700 /run/user/1000
ENV XDG_RUNTIME_DIR="/run/user/1000"

# Create dirs
RUN mkdir /workspaces

# Make sure specific dirs are owned by ubuntu user
RUN chown -R ubuntu:ubuntu /workspaces && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Change user
USER ubuntu

# Set up .bashrc
RUN ( \
    echo ""; \
    echo "# informative git"; \
    echo "source \${HOME}/.bash-git-prompt/gitprompt.sh"; \
    echo ""; \
    echo "# ros"; \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash"; \
    echo "export ROS_IP=127.0.0.1"; \
    echo "export ROS_MASTER_URI=http://\$ROS_IP:11311" \
    ) >> ~/.bashrc

# Start bash
WORKDIR /workspaces
CMD ["bash", "-i"]
