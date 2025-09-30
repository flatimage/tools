FROM alpine:latest

# Install deps
RUN apk update && apk add alpine-sdk gnupg git bash autoconf bison wget tar ncurses-libs

# Fetch source
RUN git clone https://github.com/flatimage/tools.git
WORKDIR /tools

ENV VERSION=5.3

# Download and extract bash
RUN wget http://ftpmirror.gnu.org/gnu/bash/bash-$VERSION.tar.gz
RUN tar -xf bash-$VERSION.tar.gz
RUN mv bash-$VERSION bash
WORKDIR /tools/bash

# Apply patch
RUN cd .. && patch -p1 < bash.patch

# Set compilation flags
ENV CFLAGS="${CFLAGS:-} -Os -static"
ENV CPPFLAGS="$CFLAGS"

# Compile bash
RUN autoconf -f
RUN ./configure --without-bash-malloc --enable-silent-rules
RUN make -s -j$(nproc)

# Copy static binary
RUN mkdir -p /dist
RUN cp bash /dist/bash

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded /dist/bash
