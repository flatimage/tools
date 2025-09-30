FROM alpine:latest

# Update distribution repositories
RUN echo https://dl-cdn.alpinelinux.org/alpine/v3.20/main/ > /etc/apk/repositories
RUN echo https://dl-cdn.alpinelinux.org/alpine/v3.20/community/ >> /etc/apk/repositories
RUN apk update
RUN apk add --no-cache git gcc make musl-dev autoconf automake libtool ninja \
  linux-headers bash meson cmake pkgconfig libcap-static libcap-dev \
  libselinux-dev libxslt upx

# Clone and enter project directory
RUN git clone https://github.com/flatimage/tools.git
WORKDIR tools/bwrap

# Apply patch
RUN git apply ../bwrap.patch

# Build
RUN meson build
RUN ninja -C build bwrap.p/bubblewrap.c.o bwrap.p/bind-mount.c.o bwrap.p/network.c.o bwrap.p/utils.c.o
WORKDIR build
RUN cc -o bwrap bwrap.p/bubblewrap.c.o bwrap.p/bind-mount.c.o bwrap.p/network.c.o bwrap.p/utils.c.o -static -L/usr/lib -lcap -lselinux

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap
