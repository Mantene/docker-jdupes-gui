FROM ich777/novnc-baseimage

LABEL maintainer="admin@minenet.at"

RUN export TZ=America/New_York && \
	apt-get update && \
	apt-get -y install --no-install-recommends software-properties-common bzip2 libgtk-3-0 libdbus-glib-1-2 && \
	add-apt-repository -y ppa:deadsnakes/ppa && \
	apt-get update && \
	apt-get -y install python3.9 python3-pip git &&\
	pip3 install pygobject && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	echo "ko_KR.UTF-8 UTF-8" >> /etc/locale.gen && \ 
	echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "JDupes-Gui - noVNC";' /usr/share/novnc/app/ui.js && \
	rm /usr/share/novnc/app/images/icons/*

ENV DATA_DIR=/jdupes-gui
ENV CUSTOM_RES_W=1024
ENV CUSTOM_RES_H=768
ENV CUSTOM_DEPTH=16
ENV NOVNC_PORT=8080
ENV RFB_PORT=5900
ENV TURBOVNC_PARAMS="-securitytypes none"
ENV FIREFOX_LANG="en-US"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="jdupes"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	mkdir -p /tmp/config && \
	ulimit -n 2048 && \
	git clone https://github.com/jbruchon/jdupes.git && \
	cd jdupes && make && make install && \
	git clone https://github.com/Pesc0/jdupes-gui.git && \
	mv jdupes-gui/* $DATA_DIR
	

ADD /scripts/ /opt/scripts/
COPY /icons/* /usr/share/novnc/app/images/icons/
COPY /conf/ /etc/.fluxbox/
COPY /config/ /tmp/config/
RUN chmod -R 770 /opt/scripts/

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
