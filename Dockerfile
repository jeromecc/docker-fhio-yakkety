FROM ubuntu:16.10
MAINTAINER jerome <jerome@jerome.cc>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /home/ubuntu

# built-in packages
RUN apt-get update
RUN apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages --no-install-recommends \
        curl \
        software-properties-common \
        supervisor \
        openssh-server \
        pwgen \
        sudo \
        vim-tiny \
        net-tools \
        lxde \
        x11vnc \
        xvfb \
        gtk2-engines-murrine \
        ttf-ubuntu-font-family \
        nginx \
        python-pip \
        python-dev \
        build-essential \
        mesa-utils \
        libgl1-mesa-dri \
        gnome-themes-standard \
        gtk2-engines-pixbuf \
        gtk2-engines-murrine \
        pinta \
        arc-theme
RUN apt-get autoclean
RUN apt-get autoremove

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
RUN apt-get update
RUN apt-get install -y --force-yes --no-install-recommends qt5-qmake
RUN qmake -v
#ADD qt/qt-opensource-linux-x64-5.7.0.run /home/ubuntu
#RUN chmod +x /home/ubuntu/qt-opensource-linux-x64-5.7.0.run
#ADD qt/qt_silent_install.qs /home/ubuntu
#RUN export DISPLAY=:1
#RUN Xvfb :1 -screen 0 1024x768x16 &
#RUN /home/ubuntu/qt-opensource-linux-x64-5.7.0.run --verbose --script qt_silent_install.qs &
#ADD https://github.com/FreeHealth/freehealth/releases/download/v0.9.9/freehealth-src_0.9.9.tgz /home/ubuntu
#RUN qmake /home/ubuntu/freehealth-0.9.9/freehealth/freehealth.pro -r -config release "CONFIG+=LINUX_INTEGRATED" "INSTALL_ROOT_PATH=/usr/"
#RUN cd /home/ubuntu/freehealth-0.9.9/freehealth
#RUN make
#RUN make install

EXPOSE 6080
WORKDIR /root
ENTRYPOINT ["/startup.sh"]
