FROM alpine:latest

RUN apk add --no-cache git gcc make musl-dev bash \
  pkgconfig upx fuse-static fuse-dev glib-dev \
  glib-static attr-dev attr-static

# Build
RUN git clone https://github.com/flatimage/tools.git
WORKDIR tools/ciopfs
ENV LDFLAGS="-static"
RUN make

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded ciopfs
