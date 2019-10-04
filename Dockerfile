FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG LIDARR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG LIDARR_BRANCH="netcore"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install --no-install-recommends -y \
        libchromaprint-tools \
        libsqlite3-dev \
	jq && \
 echo "**** install lidarr ****" && \
 mkdir -p /app/lidarr && \
 if [ -z ${LIDARR_RELEASE+x} ]; then \
	LIDARR_RELEASE=$(curl -sL "https://services.lidarr.audio/v1/update/nightly/changes?os=linux" \
	| jq -r '.[0].version'); \
 fi && \
 lidarr_url=$(curl -sL "https://services.lidarr.audio/v1/update/${LIDARR_BRANCH}?version=${LIDARR_RELEASE}&os=linux&runtime=netcore&arch=x64" \
	| jq -r '.updatePackage.url') && \
 curl -o \
 /tmp/lidarr.tar.gz -L \
	"${lidarr_url}" && \
 tar ixzf \
 /tmp/lidarr.tar.gz -C \
	/app/lidarr --strip-components=1 && \
 echo "**** cleanup ****" && \
 rm -rf \
	/app/lidarr/Lidarr.Update \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8686
VOLUME /config /downloads /music
