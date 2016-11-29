FROM ubuntu:14.04
MAINTAINER Doro Wu <fcwu.tw@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /home/ubuntu

# built-in packages
RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends software-properties-common curl \
    && sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | sudo apt-key add - \
    && add-apt-repository ppa:fcwu-tw/ppa \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
        supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        fonts-wqy-microhei \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ADD web /web/
RUN pip install setuptools wheel && pip install -r /web/requirements.txt

# tini for subreap                                   
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD noVNC /noVNC/
ADD nginx.conf /etc/nginx/sites-enabled/default
ADD startup.sh /
ADD supervisord.conf /etc/supervisor/conf.d/
ADD doro-lxde-wallpapers /usr/share/doro-lxde-wallpapers/
ADD gtkrc-2.0 /home/ubuntu/.gtkrc-2.0
ADD qt/qt_silent_install.qs /home/ubuntu
ADD qt/qt-opensource-linux-x64-5.7.0.run /home/ubuntu
RUN chmod +x /home/ubuntu/qt-opensource-linux-x64-5.7.0.run
RUN export DISPLAY=:1
RUN Xvfb :1 -screen 0 1024x768x16 &
RUN /home/ubuntu/qt-opensource-linux-x64-5.7.0.run --verbose --script qt_silent_install.qs &
ADD https://github.com/FreeHealth/freehealth/releases/download/v0.9.9/freehealth-src_0.9.9.tgz /home/ubuntu
RUN qmake /home/ubuntu/freehealth-0.9.9/freehealth/freehealth.pro -r -config release "CONFIG+=LINUX_INTEGRATED" "INSTALL_ROOT_PATH=/usr/"
RUN cd /home/ubuntu/freehealth-0.9.9/freehealth
RUN make
RUN make install

EXPOSE 6080
WORKDIR /root
ENTRYPOINT ["/startup.sh"]
