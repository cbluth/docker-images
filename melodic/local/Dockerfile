FROM nvidia/cuda:11.4.2-base-ubuntu18.04
LABEL org.opencontainers.image.title="ROS Melodic"
LABEL org.opencontainers.image.description="A full Ubuntu environment."
LABEL org.opencontainers.image.source="https://github.com/ssilenzi/docker-images"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"
ENV ROS_DISTRO=melodic

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install essentials
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y apt-utils software-properties-common apt-transport-https sudo \
    psmisc lsb-release nano wget curl telnet gnupg build-essential gdb git \
    cmake autoconf automake locales gdebi dos2unix bash-completion \
    tzdata ssl-cert less zip unzip ccache clang-format-10 \
    gedit nautilus x11-apps && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/*

# Time zone and locale
ENV TZ="Europe/Rome"
RUN date && (echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections) && locale-gen en_US.UTF-8

# Install graphics
RUN apt-get update && \
    apt-get install -y mate-desktop-environment mate-panel xserver-xorg-video-dummy xserver-xorg-legacy caja \
    pluma terminator x11vnc && \
    apt-get purge --autoremove -y mate-power-manager indicator-applet-complete && \
    rm -Rf /var/lib/apt/lists/* && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
COPY xorg.conf /etc/X11/xorg.conf
RUN dos2unix /etc/X11/xorg.conf

# Install x11vnc
COPY x11vnc.sh .
RUN bash x11vnc.sh

# Install noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    echo "<html><head><meta http-equiv=\"Refresh\" content=\"0; url=vnc.html?autoconnect=true&reconnect=true&reconnect_delay=1000&resize=scale&quality=9\"></head></html>" > /opt/novnc/index.html

# ROS
RUN curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/ros.gpg && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/ros-latest.list && \
    apt-get update && \
    apt-get install -y ros-${ROS_DISTRO}-ros-base python-catkin-tools python-rosdep \
    python-rosinstall python-rosinstall-generator python-wstool && \
    rosdep init && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/*

# Install Python
RUN apt-get update && \
    apt-get install -y python-autopep8 python-dev python-pip python-pycodestyle python-setuptools \
    python-virtualenv python-wheel && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/*

# Install jupyter
RUN pip install --upgrade pip wheel setuptools virtualenv && \
    pip install --ignore-installed ipython jupyter jupyterlab notebook testresources && \
    rm -rf /root/.cache
COPY start-jupyter /usr/bin/start-jupyter
RUN chmod +x /usr/bin/start-jupyter && \
    dos2unix /usr/bin/start-jupyter

# Install Smartgit
COPY smartgit /usr/bin/
RUN apt-get update && \
    wget -O smart.deb https://www.syntevo.com/downloads/smartgit/smartgit-21_1_3.deb && \
    gdebi -n smart.deb && \
    rm smart.deb && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/* && \
    chmod +x /usr/bin/smartgit && \
    dos2unix /usr/bin/smartgit

# Create user ubuntu
RUN useradd -l -u 1000 -G sudo -md /home/ubuntu -s /bin/bash ubuntu && \
    yes ubuntu | passwd ubuntu && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Switch to ubuntu user
USER ubuntu

ENV DISPLAY=:0
ENV PATH="/usr/lib/ccache:/home/ubuntu/.local/bin:/usr/share/smartgit/bin:${PATH}"

# Install informative git for bash
ENV GIT_PROMPT_ONLY_IN_REPO=1
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

# Switch back to root
USER root

# Set up ccache
RUN cp /usr/bin/ccache /usr/local/bin/ && \
    ln -s /usr/bin/ccache /usr/local/bin/gcc && \
    ln -s /usr/bin/ccache /usr/local/bin/g++ && \
    ln -s /usr/bin/ccache /usr/local/bin/cc  && \
    ln -s /usr/bin/ccache /usr/local/bin/c++

# Set up script to launch graphics and vnc
COPY start-vnc-session.sh /usr/bin/start-vnc-session.sh
RUN chmod +x /usr/bin/start-vnc-session.sh && \
    dos2unix /usr/bin/start-vnc-session.sh

# Create workspace
RUN mkdir /workspaces && \
    mkdir /home/ubuntu/Desktop && \
    mkdir /home/ubuntu/.config && \
    touch /home/ubuntu/.config/mimeapps.list

# Setup icons
COPY ["chromium-browser.desktop", "/usr/share/applications/chromium-browser.desktop"]
RUN cp /usr/share/applications/chromium-browser.desktop /home/ubuntu/Desktop/chromium-browser.desktop && \
    cp /usr/share/applications/syntevo-smartgit.desktop /home/ubuntu/Desktop/syntevo-smartgit.desktop && \
    cp /usr/share/applications/terminator.desktop /home/ubuntu/Desktop/terminator.desktop && \
    find /home/ubuntu/Desktop -type f -name *.desktop | xargs -I{} \
    sh -c 'chmod 755 {} && dos2unix {} > /dev/null 2>&1' && \
    find /usr/share/applications -type f -name *.desktop | xargs -I{} \
    sh -c 'chmod 755 {} && dos2unix {} > /dev/null 2>&1'

# Make sure specific dirs are owned by ubuntu user
RUN chown -R ubuntu:ubuntu /workspaces && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Change user and trust shortcuts
USER ubuntu
RUN xdg-settings set default-web-browser chromium-browser.desktop && \
    find /home/ubuntu/Desktop -type f -name *.desktop | xargs -I{} dbus-launch gio set {} metadata::trusted yes && \
    find /usr/share/applications -type f -name *.desktop | xargs -I{} dbus-launch gio set {} metadata::trusted yes

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
CMD start-vnc-session.sh && \
    bash -i
