FROM ubuntu:18.04
LABEL org.opencontainers.image.title="ROS Melodic + Gazebo"
LABEL org.opencontainers.image.description="A full Ubuntu lxQt environment."
LABEL org.opencontainers.image.source="https://github.com/ssilenzi/melodic"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils software-properties-common apt-transport-https sudo \
    psmisc lsb-release nano wget curl telnet gnupg build-essential gdb git \
    cmake autoconf automake locales gdebi dos2unix bash-completion \
    tzdata ssl-cert less zip unzip

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
    chromium-browser featherpad firefox terminator && \
    apt remove --autoremove -y lxqt-powermanagement && \
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

# Install Python
RUN apt install -y python python-dev python-pip python-setuptools python-virtualenv python-wheel \
    python3 python3-autopep8 python3-dev python3-pip python3-pycodestyle python3-setuptools python3-virtualenv python3-wheel

# Install ROS
ENV ROS_DISTRO=melodic
RUN curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/ros.gpg && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/ros-latest.list && \
    apt update && \
    apt install -y ros-${ROS_DISTRO}-desktop-full ros-${ROS_DISTRO}-moveit python-catkin-tools python-rosdep \
    python-rosinstall python-rosinstall-generator python-wstool && \
    rosdep init

# Purge man-db
RUN apt purge --autoremove -y man-db

# Install VSCode
# better off downling the deb file than relying on packages.microsoft.com sources that are often broken
ENV DONT_PROMPT_WSL_INSTALL=1
RUN wget -O code.deb https://go.microsoft.com/fwlink/?LinkID=760868 && \
    gdebi -n code.deb && \
    rm code.deb

# Install Octave
RUN apt install -y octave epstool transfig

# Install markserv
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash - && \
    apt update && \
    apt install -y nodejs && \
    npm install --global markserv

# Install jupyter
RUN pip3 install --ignore-installed ipython jupyter jupyterlab notebook testresources

# Install magic-wormwhole to get things from one computer to another safely
RUN apt install -y magic-wormhole

# Create user gitpod
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Switch to gitpod user
USER gitpod

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

# Code plugins
RUN code --install-extension ms-vscode.cpptools
RUN code --install-extension ms-python.python
RUN code --install-extension ms-toolsai.jupyter
RUN code --install-extension davidanson.vscode-markdownlint
RUN code --install-extension sweilz.ros-snippets
RUN code --install-extension ms-iot.vscode-ros

# Set up .bashrc
# "/usr/bin" needs to come in the first place within PATH to shadow "/ide/bin/code"
WORKDIR /home/gitpod
RUN ( \
    echo ""; \
    echo "export PATH=/usr/bin:/home/gitpod/.local/bin:\${PATH}"; \
    echo ""; \
    echo "export GIT_PROMPT_ONLY_IN_REPO=1"; \
    echo "source \${HOME}/.bash-git-prompt/gitprompt.sh"; \
    echo ""; \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash"; \
    echo "source `catkin locate --shell-verbs`"; \
    echo "export ROS_IP=127.0.0.1"; \
    echo "export ROS_MASTER_URI=http://\$ROS_IP:11311"; \
    ) >> ~/.bashrc

# Switch back to root
USER root

# Clean up unnecessary installation products
RUN apt clean && \
    rm -Rf /var/lib/apt/lists/*

# Set up script to launch markserv
COPY start-markserv.sh /usr/bin/start-markserv.sh
RUN chmod +x /usr/bin/start-markserv.sh && \
    dos2unix /usr/bin/start-markserv.sh

# Set up script to launch jupyter
COPY start-jupyter.sh /usr/bin/start-jupyter.sh
RUN chmod +x /usr/bin/start-jupyter.sh && \
    dos2unix /usr/bin/start-jupyter.sh

# Set up script to launch graphics and vnc
COPY start-vnc-session.sh /usr/bin/start-vnc-session.sh
COPY restart-vnc-session.sh /usr/bin/restart-vnc-session.sh
RUN chmod +x /usr/bin/start-vnc-session.sh && \
    dos2unix /usr/bin/start-vnc-session.sh

# Create workspace
RUN mkdir /workspace && \
    mkdir /home/gitpod/Desktop && \
    touch /home/gitpod/.config/mimeapps.list

# Set up VSCode launcher
COPY ["chromium-browser.desktop", "/usr/share/applications/chromium-browser.desktop"]
COPY ["code.desktop", "/usr/share/applications/code.desktop"]
RUN cp /usr/share/applications/chromium-browser.desktop /home/gitpod/Desktop/chromium-browser.desktop && \
    cp /usr/share/applications/code.desktop /home/gitpod/Desktop/code.desktop && \
    cp /usr/share/applications/firefox.desktop /home/gitpod/Desktop/firefox.desktop && \
    cp /usr/share/applications/pcmanfm-qt.desktop /home/gitpod/Desktop/pcmanfm-qt.desktop && \
    cp /usr/share/applications/terminator.desktop /home/gitpod/Desktop/terminator.desktop && \
    find /home/gitpod/Desktop -type f -name *.desktop | xargs -I{} \
    sh -c 'chmod 755 {} && dos2unix {} > /dev/null 2>&1' && \
    find /usr/share/applications -type f -name *.desktop | xargs -I{} \
    sh -c 'chmod 755 {} && dos2unix {} > /dev/null 2>&1'

# Make sure specific dirs are owned by gitpod user
RUN chown -R gitpod:gitpod /workspace && \
    chown -R gitpod:gitpod /home/gitpod

# Change user and trust shortcuts
USER gitpod
RUN xdg-settings set default-web-browser chromium-browser.desktop && \
    find /home/gitpod/Desktop -type f -name *.desktop | xargs -I{} dbus-launch gio set {} metadata::trusted yes && \
    find /usr/share/applications -type f -name *.desktop | xargs -I{} dbus-launch gio set {} metadata::trusted yes

# Launch bash from /workspace
USER root
WORKDIR /workspace
CMD ["bash"]
