FROM alpine:latest

# Requirements
RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/main/ > /etc/apk/repositories
RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories
RUN apk update && apk upgrade
RUN apk add --no-cache build-base linux-headers git upx

# Source
RUN git clone https://github.com/flatimage/tools.git
WORKDIR tools/busybox

# Static binary
ENV LDFLAGS="-static"

# Build
RUN make defconfig
RUN sed -i "s/CONFIG_SHA1_HWACCEL=y/CONFIG_SHA1_HWACCEL=n/" .config
RUN sed -i "s/CONFIG_SHA256_HWACCEL=y/CONFIG_SHA256_HWACCEL=n/" .config
## Causes the compilation to break if turn on
RUN sed -i "s/CONFIG_TC=y/CONFIG_TC=n/" .config
RUN make -j"$(nproc)"

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded busybox
