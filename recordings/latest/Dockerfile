FROM ubuntu:20.04
LABEL org.opencontainers.image.title="Focal lxQt recordings"
LABEL org.opencontainers.image.description="A full Ubuntu lxQt environment optimized for recordings."
LABEL org.opencontainers.image.source="https://github.com/ssilenzi/recordings"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update && \
    apt dist-upgrade -y

# Install essentials
RUN apt install -y build-essential gcc g++ make ninja-build cmake autoconf automake \
    git apt-utils software-properties-common apt-transport-https sudo nano telnet \
    bash-completion gdebi wget curl dos2unix tar zip python locales locales-all tzdata \
    ca-certificates

# Set the locale
RUN locale-gen en_US.UTF-8

# Set environmental variables
ENV DISPLAY=:1

# Time zone
ENV TZ="Europe/Rome"
RUN date > /dev/null

# Install graphics
RUN apt install -y lxqt-core lightdm xfwm4 xserver-xorg-video-dummy xserver-xorg-legacy x11vnc \
    terminator featherpad firefox && \
    apt remove --autoremove -y gdm3 mutter lxqt-powermanagement && \
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

# Install OBS
RUN add-apt-repository -y ppa:obsproject/obs-studio && \
    apt update && \
    apt install -y ffmpeg obs-studio

# Install Zoom
RUN wget -O zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb && \
    gdebi -n zoom_amd64.deb && \
    rm zoom_amd64.deb

# Install Teams
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list && \
    apt update && \
    apt install teams

# Create user ubuntu
RUN useradd -l -u 1000 -G sudo,audio -md /home/ubuntu -s /bin/bash -p ubuntu ubuntu && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Set up script to launch graphics and vnc
COPY start-vnc-session.sh /usr/bin/start-vnc-session.sh
RUN chmod +x /usr/bin/start-vnc-session.sh && \
    dos2unix /usr/bin/start-vnc-session.sh

# Create workspace
RUN mkdir /workspace && \
    mkdir /home/ubuntu/Desktop && \
    mkdir -p /home/ubuntu/.config/obs-studio

# Copy desktop shortcuts
COPY ["chromium-browser.desktop", "/usr/share/applications/chromium-browser.desktop"]
RUN cp /usr/share/applications/chromium-browser.desktop /home/ubuntu/Desktop/chromium-browser.desktop && \
    cp /usr/share/applications/firefox.desktop /home/ubuntu/Desktop/firefox.desktop && \
    cp /usr/share/applications/pcmanfm-qt.desktop /home/ubuntu/Desktop/pcmanfm-qt.desktop && \
    cp /usr/share/applications/terminator.desktop /home/ubuntu/Desktop/terminator.desktop && \
    cp /usr/share/applications/com.obsproject.Studio.desktop /home/ubuntu/Desktop/com.obsproject.Studio.desktop && \
    cp /usr/share/applications/Zoom.desktop /home/ubuntu/Desktop/Zoom.desktop && \
    cp /usr/share/applications/teams.desktop /home/ubuntu/Desktop/teams.desktop && \
    find /home/ubuntu/Desktop -type f -name *.desktop | xargs -I{} bash -c \
    'chmod 755 {} && dos2unix {} > /dev/null 2>&1' && \
    find /usr/share/applications -type f -name *.desktop | xargs -I{} bash -c \
    'chmod 755 {} && dos2unix {} > /dev/null 2>&1'

# Copy OBS settings
COPY ["obs-studio", "/home/ubuntu/.config/obs-studio/"]
RUN find /home/ubuntu/.config/obs-studio -type f -name *.* | xargs -I{} bash -c \
    'chmod 755 {} && dos2unix {} > /dev/null 2>&1'

# Make sure specific dirs are owned by ubuntu user
RUN chown -R ubuntu:ubuntu /workspace && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Clean up unnecessary installation products
RUN apt clean && rm -Rf /var/lib/apt/lists/*

# Change user and trust shortcuts
USER ubuntu
RUN find /home/ubuntu/Desktop -type f -name *.desktop | xargs -I{} dbus-launch gio set {} metadata::trusted true && \
    find /usr/share/applications -type f -name *.desktop | xargs -I{} dbus-launch gio set {} metadata::trusted true

# Launch bash from /workspace
WORKDIR /workspace
CMD ["bash", "-c", "start-vnc-session.sh && bash"]
