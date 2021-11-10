ARG ROS_DISTRO=noetic
FROM ros:${ROS_DISTRO}-ros-base
LABEL org.opencontainers.image.title="ROS Noetic"
LABEL org.opencontainers.image.description="A full Ubuntu environment."
LABEL org.opencontainers.image.source="https://github.com/ssilenzi/docker-images"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"
ENV ROS_DISTRO=noetic

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils software-properties-common apt-transport-https sudo \
    psmisc lsb-release nano wget curl telnet gnupg build-essential gdb git \
    cmake autoconf automake locales gdebi dos2unix bash-completion \
    tzdata ssl-cert less zip unzip ccache

# Time zone
ENV TZ="Europe/Rome"
RUN date > /dev/null    

# Set the locale
RUN locale-gen en_US.UTF-8

# Install LLVM
RUN curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | \
    gpg --dearmor -o /etc/apt/trusted.gpg.d/llvm-snapshot.gpg && \
    add-apt-repository "deb http://apt.llvm.org/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc)-13 main" && \
    apt update && \
    apt dist-upgrade -y && \
    apt install -y --install-recommends clang-13 clangd-13 clang-format-13 clang-tidy-13 lld-13 llvm-13 && \
    sed -i '/llvm/d' /etc/apt/sources.list && \
    rm /etc/apt/trusted.gpg.d/llvm-snapshot.gpg

# Install Python
RUN apt install -y python3 python3-autopep8 python3-dev python3-pip python3-pycodestyle python3-setuptools python3-virtualenv python3-wheel

# Install Smartgit
RUN wget -O smart.deb https://www.syntevo.com/downloads/smartgit/smartgit-21_1_3.deb && \
    gdebi -n smart.deb && \
    rm smart.deb

# Create user ubuntu
RUN useradd -l -u 1000 -G sudo -md /home/ubuntu -s /bin/bash ubuntu && \
    yes ubuntu | passwd ubuntu && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Switch to ubuntu user
USER ubuntu

# Rosdep update
RUN rosdep update

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

# Clean up unnecessary installation products
RUN apt clean && \
    rm -Rf /var/lib/apt/lists/*

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
