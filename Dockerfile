FROM lsiobase/mono:LTS

# set version label
ARG BUILD_DATE
ARG VERSION
ARG READARR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG READARR_BRANCH="readarr"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install --no-install-recommends -y \
	libchromaprint-tools \
	jq && \
 echo "**** install readarr ****" && \
 mkdir -p /app/readarr && \
 if [ -z ${READARR_RELEASE+x} ]; then \
	READARR_RELEASE=$(curl -sL "https://NOT_PUBLIC_YET/v1/update/${READARR_BRANCH}/changes?os=linux" \
	| jq -r '.[0].version'); \
 fi && \
 readarr_url=$(curl -sL "https://NOT_PUBLIC_YET/v1/update/${READARR_BRANCH}/changes?os=linux" \
	| jq -r "first(.[] | select(.version == \"${READARR_RELEASE}\")) | .url") && \
 curl -o \
 /tmp/readarr.tar.gz -L \
	"${readarr_url}" && \
 tar ixzf \
 /tmp/readarr.tar.gz -C \
	/app/readarr --strip-components=1 && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8686
VOLUME /config /downloads /books
