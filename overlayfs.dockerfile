FROM alpine:latest

RUN apk add git make gcc libc-dev musl-dev glib-static gettext eudev-dev \
	linux-headers automake autoconf cmake meson ninja clang go-md2man

# Install libfuse
RUN git clone https://github.com/libfuse/libfuse -b fuse-3.16.2 && \
    cd libfuse && \
    mkdir build && \
    cd build && \
    LDFLAGS="-lpthread -s -w -static" meson --prefix /usr -D default_library=static .. && \
    ninja && \
    ninja install

# Compile fuse-overlayfs
RUN git clone https://github.com/flatimage/tools.git
RUN cd /tools/overlayfs && \
    ./autogen.sh && \
    LIBS="-ldl" LDFLAGS="-s -w -static" ./configure --prefix /usr && \
    make clean && \
    make
