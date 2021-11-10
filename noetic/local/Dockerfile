FROM ubuntu:20.04
LABEL org.opencontainers.image.title="ROS Noetic + Gazebo"
LABEL org.opencontainers.image.description="A full Ubuntu lxQt environment."
LABEL org.opencontainers.image.source="https://github.com/ssilenzi/noetic"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils software-properties-common apt-transport-https sudo \
    psmisc lsb-release nano wget curl telnet gnupg build-essential gdb git \
    cmake autoconf automake locales gdebi dos2unix bash-completion \
    tzdata ssl-cert less zip unzip rsync

# Set environmental variables
ENV DISPLAY=:1
ENV LD_LIBRARY_PATH=/usr/local/lib

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

# Install graphics
RUN apt install -y lxqt-core lightdm xfwm4 xserver-xorg-video-dummy xserver-xorg-legacy \
    featherpad terminator x11vnc && \
    apt remove --autoremove -y lxqt-powermanagement mutter && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
COPY xorg.conf /etc/X11/xorg.conf
RUN dos2unix /etc/X11/xorg.conf

# Install Chromium
RUN add-apt-repository -y ppa:saiarcot895/chromium-beta && \
    echo "Package: *" >> /etc/apt/preferences.d/pin-chromium-deb && \
    echo "Pin: release o=LP-PPA-saiarcot895-chromium-beta" >> /etc/apt/preferences.d/pin-chromium-deb && \
    echo "Pin-Priority: 1337" >> /etc/apt/preferences.d/pin-chromium-deb && \
    apt update && \
    apt install -y chromium-browser

# Install noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    echo "<html><head><meta http-equiv=\"Refresh\" content=\"0; url=vnc.html?autoconnect=true&reconnect=true&reconnect_delay=1000&resize=scale&quality=9\"></head></html>" > /opt/novnc/index.html

# Install Python
RUN apt install -y python3 python3-autopep8 python3-dev python3-pip python3-pycodestyle python3-setuptools python3-virtualenv python3-wheel

# Install ROS
ENV ROS_DISTRO=noetic
RUN curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/ros.gpg && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/ros-latest.list && \
    apt update && \
    apt install -y ros-${ROS_DISTRO}-desktop-full ros-${ROS_DISTRO}-moveit python3-catkin-tools python3-rosdep \
    python3-rosinstall python3-rosinstall-generator python3-wstool && \
    rosdep init

# Install ssh
RUN apt install -y ssh && \
    mkdir -p /var/run/sshd
    
# Install Smartgit
RUN wget -O smart.deb https://www.syntevo.com/downloads/smartgit/smartgit-21_1_3.deb && \
    gdebi -n smart.deb && \
    rm smart.deb

# Purge man-db
RUN apt purge --autoremove -y man-db

# Create user ubuntu
RUN useradd -l -u 1000 -G sudo -md /home/ubuntu -s /bin/bash ubuntu && \
    yes ubuntu | passwd ubuntu && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers && \
    # sshd config
    ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
    ) > /etc/ssh/sshd_config 

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

# Install informative git for bash
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

# Install GitHub CLI
RUN brew install gh

# Switch back to root
USER root

# Clean up unnecessary installation products
RUN apt clean && \
    rm -Rf /var/lib/apt/lists/*

# Set up script to launch graphics and vnc
COPY start-vnc-session.sh /usr/bin/start-vnc-session.sh
RUN chmod +x /usr/bin/start-vnc-session.sh && \
    dos2unix /usr/bin/start-vnc-session.sh

# Create workspace
RUN mkdir /workspace && \
    mkdir /home/ubuntu/Desktop && \
    mkdir /home/ubuntu/.config && \
    touch /home/ubuntu/.config/mimeapps.list

# Setup icons
COPY ["chromium-browser.desktop", "/usr/share/applications/chromium-browser.desktop"]
RUN cp /usr/share/applications/chromium-browser.desktop /home/ubuntu/Desktop/chromium-browser.desktop && \
    cp /usr/share/applications/pcmanfm-qt.desktop /home/ubuntu/Desktop/pcmanfm-qt.desktop && \
    cp /usr/share/applications/syntevo-smartgit.desktop /home/ubuntu/Desktop/syntevo-smartgit.desktop && \
    cp /usr/share/applications/terminator.desktop /home/ubuntu/Desktop/terminator.desktop && \
    find /home/ubuntu/Desktop -type f -name *.desktop | xargs -I{} \
    sh -c 'chmod 755 {} && dos2unix {} > /dev/null 2>&1' && \
    find /usr/share/applications -type f -name *.desktop | xargs -I{} \
    sh -c 'chmod 755 {} && dos2unix {} > /dev/null 2>&1'

# Make sure specific dirs are owned by ubuntu user
RUN chown -R ubuntu:ubuntu /workspace && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Change user and trust shortcuts
USER ubuntu
RUN xdg-settings set default-web-browser chromium-browser.desktop && \
    find /home/ubuntu/Desktop -type f -name *.desktop | xargs -I{} dbus-launch gio set {} metadata::trusted true && \
    find /usr/share/applications -type f -name *.desktop | xargs -I{} dbus-launch gio set {} metadata::trusted true

# Set up .bashrc
RUN ( \
    echo ""; \
    echo "export PATH=/usr/bin:/home/ubuntu/.local/bin:\${PATH}"; \
    echo ""; \
    echo "# informative git"; \
    echo "export GIT_PROMPT_ONLY_IN_REPO=1"; \
    echo "source \${HOME}/.bash-git-prompt/gitprompt.sh"; \
    echo ""; \
    echo "# ros"; \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash"; \
    echo "source `catkin locate --shell-verbs`"; \
    echo "export ROS_IP=127.0.0.1"; \
    echo "export ROS_MASTER_URI=http://\$ROS_IP:11311" \
    ) >> ~/.bashrc

# Start bash
WORKDIR /workspace
CMD start-vnc-session.sh && \
    sudo -H /usr/sbin/sshd -D -e
