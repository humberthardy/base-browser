FROM ubuntu:bionic

RUN apt-get -y update

# Prepare tz

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && dpkg-reconfigure -f noninteractive tzdata


RUN apt-get -qqy --no-install-recommends install \
    git \
    sudo \
    #python2.7 \
    python3-pip \
    python3-dev \
    build-essential \
    python3-openssl \
    libssl-dev libffi-dev \
    net-tools \
    libnss3-tools \
    x11vnc \
    xvfb \
    curl \
    wget \
    vim \
    socat \
    jwm \
    autocutsel \
    dnsutils \
    pulseaudio \
    libopus-dev \
    gstreamer-1.0 \
    gstreamer1.0-tools \
    gstreamer1.0-alsa \
    gstreamer1.0-nice \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad



# sudo
RUN useradd browser --shell /bin/bash --create-home \
  && usermod -a -G sudo browser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'browser:secret' | chpasswd


# fonts
RUN apt-get -qqy --no-install-recommends install \
    fonts-ipafont-gothic \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    xfonts-scalable \
    xfonts-base \
    fonts-liberation \
    fonts-arphic-bkai00mp \
    fonts-arphic-bsmi00lp \
    fonts-arphic-gbsn00lp \
    fonts-arphic-gkai00mp \
    fonts-arphic-ukai \
    fonts-farsiweb \
    fonts-nafees \
    fonts-sil-abyssinica \
    fonts-sil-ezra \
    fonts-sil-padauk \
    fonts-unfonts-extra \
    fonts-unfonts-core \
    fonts-indic \
    fonts-thai-tlwg \
    fonts-lklug-sinhala


# fix module-console-kit for opus
RUN sed -i '/load-module module-console-kit/s/^/#/' /etc/pulse/default.pa


WORKDIR /app/

COPY requirements.txt /app/

COPY jwmrc /home/browser/.jwmrc

RUN pip3 install -U setuptools pip

RUN pip3 install -U -r requirements.txt



ADD run_browser /usr/bin/run_browser

#ADD ffmpeg3.2.tar.gz /app/
COPY audio/audio_proxy.py /app/audio_proxy.py
COPY audio/audio_stream.sh /app/audio_stream.sh
COPY audio/webrtc-send-webrecorder /app/webrtc-send-webrecorder




COPY entry_point.sh /app/entry_point.sh

EXPOSE 6080
EXPOSE 6082

ENV TS 1996
ENV URL about:blank

ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 16
ENV DISPLAY :99

ENV PROXY_PORT 8080
ENV PROXY_GET_CA http://mitm.it/cert/pem
ENV IDLE_TIMEOUT ""
ENV AUDIO_TYPE ""


RUN rm -rf /var/lib/apt/lists/*

CMD /app/entry_point.sh
