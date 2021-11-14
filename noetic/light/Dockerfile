FROM nvidia/cuda:11.4.2-base-ubuntu20.04
LABEL org.opencontainers.image.title="ROS Noetic"
LABEL org.opencontainers.image.description="A full Ubuntu environment."
LABEL org.opencontainers.image.source="https://github.com/ssilenzi/docker-images"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"
ENV ROS_DISTRO=noetic

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install essentials
RUN apt-get update && \
    apt-get install -y apt-utils software-properties-common apt-transport-https sudo \
    psmisc lsb-release nano wget curl telnet gnupg build-essential gdb git \
    cmake autoconf automake locales gdebi dos2unix bash-completion \
    tzdata ssl-cert less zip unzip ccache clang-format-10 && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/*

# Time zone and locale
ENV TZ="Europe/Rome"
RUN date && (echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections) && locale-gen en_US.UTF-8

# ROS
RUN curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/ros.gpg && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/ros-latest.list && \
    apt-get update && \
    apt-get install -y ros-${ROS_DISTRO}-ros-base python3-catkin-tools python3-rosdep \
    python3-rosinstall python3-rosinstall-generator python3-wstool && \
    rosdep init && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/*

# Install Python
RUN apt-get update && \
    apt-get install -y python3-autopep8 python3-dev python3-pip python3-pycodestyle python3-setuptools \
    python3-virtualenv python3-wheel && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/*

# Install jupyter
RUN pip3 install --ignore-installed ipython jupyter jupyterlab notebook testresources
COPY start-jupyter /usr/bin/start-jupyter
RUN chmod +x /usr/bin/start-jupyter && \
    dos2unix /usr/bin/start-jupyter

# Install Smartgit
RUN apt-get update && \
    wget -O smart.deb https://www.syntevo.com/downloads/smartgit/smartgit-21_1_3.deb && \
    gdebi -n smart.deb && \
    rm smart.deb && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/*

# Create user ubuntu
RUN useradd -l -u 1000 -G sudo -md /home/ubuntu -s /bin/bash ubuntu && \
    yes ubuntu | passwd ubuntu && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Switch to ubuntu user
USER ubuntu

# Install Homebrew
RUN mkdir ~/.cache && bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
ENV PATH="${PATH}:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin/"
ENV MANPATH="${MANPATH}:/home/linuxbrew/.linuxbrew/share/man"
ENV INFOPATH="${INFOPATH}:/home/linuxbrew/.linuxbrew/share/info"
ENV HOMEBREW_NO_AUTO_UPDATE=1
ENV GIT_PROMPT_ONLY_IN_REPO=1

# Set up env variables
ENV PATH="/home/ubuntu/.local/bin:/usr/local/bin:/usr/share/smartgit/bin:${PATH}"

# Install informative git for bash
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

# Switch back to root
USER root

# Create workspace
RUN mkdir /workspace

# Make sure specific dirs are owned by ubuntu user
RUN chown -R ubuntu:ubuntu /workspace && \
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
WORKDIR /workspace
CMD ["bash"]
