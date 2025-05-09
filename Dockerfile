ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8

RUN apk update
RUN apk add --no-cache --virtual .build-deps alpine-keys bash automake make git rsync tar gcc g++ \
  binutils libstdc++ libgfortran readline readline-dev python3-dev dev86 m4 libtool autoconf swig \
  linux-headers build-base util-linux \
  && apk add --no-cache libftdi1-dev libusb libusb-dev libgcc \
  && CPUS=`lscpu | grep -E '^CPU\(' |awk '{print $2}'` \
  && git clone --single-branch --branch v3.2p4 --depth 1 https://github.com/owfs/owfs /owfs-code \
  && cd /owfs-code \
  && git pull \
  && sed -i "s/A HREF='%\.\*s'/A HREF='.\/.\/.\/.\/'/gI" /owfs-code/module/owhttpd/src/c/owhttpd_dir.c \
  && sed -i "s/A HREF='%s'/A HREF='.%s'/gI" /owfs-code/module/owhttpd/src/c/owhttpd_dir.c \
  && sed -i "s/A HREF='\/'/A HREF='.\/.\/.\/.\/'/gI" /owfs-code/module/owhttpd/src/c/owhttpd_dir.c \
  && sed -i "s/A HREF='%\.\*s'/A HREF='.\/.\/.\/.\/'/gI" /owfs-code/module/owhttpd/src/c/owhttpd_read.c \
  && sed -i "s/A HREF='%s'/A HREF='.%s'/gI" /owfs-code/module/owhttpd/src/c/owhttpd_read.c \
  && sed -i "s/A HREF='\/uncached/A HREF='.\/uncached/gI" /owfs-code/module/owhttpd/src/c/owhttpd_read.c \
  && sed -i "s/A HREF='\/'/A HREF='.\/.\/.\/.\/'/gI" /owfs-code/module/owhttpd/src/c/owhttpd_present.c \
  && ./bootstrap \
  && ./configure \
    --disable-owftpd \
    --enable-owexternal \
    --enable-ownet \
    --enable-owcapi \
    --disable-owperl \
    --disable-owphp \
    --disable-owpython \
    --enable-owtcl \
    --disable-owtap \
    --enable-owmon \
    --enable-owfs \
    --disable-zero \
    --disable-avahi \
    --enable-debug \
    --enable-owserver \
    --enable-owhttpd \
    --enable-ftdi \
    --enable-usb \
    --enable-owshell \
    --enable-w1 \
  && make -j $CPUS && make install \
  && cd / && rm -rf /owfs-code && apk del .build-deps
	
# Copy data for add-on
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION
ARG BUILD_REPOSITORY

ENV PATH="/opt/owfs/bin:${PATH}"

# Labels
LABEL \
  io.hass.name="owserver" \
  io.hass.description="onewire server to read 1-Wire devices" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  io.hass.version=${BUILD_VERSION} \
  maintainer="Sergejs Litvinovskis <strike56@gmail.com>" \
  org.opencontainers.image.authors="Sergejs Litvinovskis <strike56@gmail.com>" \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
  org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/master/README.md" 