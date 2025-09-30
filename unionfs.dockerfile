FROM alpine:latest

# Install deps
RUN apk update && apk upgrade
RUN apk add --no-cache git build-base linux-headers cmake libbsd-dev fuse-dev \
  fuse3-dev fuse3-static upx

# Fetch source
RUN git clone https://github.com/flatimage/tools.git
ENV LD_FLAGS="-static"
WORKDIR tools/unionfs

# Patch
RUN git apply ../unionfs.patch

# Compile
RUN cmake -H. -DWITH_LIBFUSE3=TRUE -DWITH_XATTR=TRUE -Bbuild
RUN cmake --build build

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded build/src/unionfs

# Copy to distribution directory
RUN mkdir -p /dist && cp build/src/unionfs /dist/unionfs
