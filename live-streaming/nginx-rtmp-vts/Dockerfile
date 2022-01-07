# The MIT License (MIT)
#
# Copyright (c) 2016 Alfred Gutierrez
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM debian:bullseye AS nginx-builder
ARG MAKEFLAGS="-j"
RUN mkdir /code
COPY ./Makefile /code/Makefile
RUN apt-get update
RUN apt-get upgrade
RUN apt-get install -y build-essential \
	make \
	wget \
	libpcre3-dev \
	libssl-dev \
	zlib1g-dev
RUN make -C /code
RUN make -C /code install

FROM debian:bullseye as ffmpeg-builder
ARG FFMPEG_VERSION=4.4.1
ARG PREFIX=/usr/local
ARG MAKEFLAGS="-j"

# Add non-free repos
COPY ./sources.list /etc/apt/sources.list

# FFmpeg build dependencies.
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get build-dep ffmpeg -y
RUN apt-get install wget -y

# Install non-free deps
RUN apt-get update
RUN apt-get -y install libbluray-dev libfaac-dev libfdk-aac-dev

# Get FFmpeg source.
RUN cd /tmp/ &&  \
	wget "http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz" &&  \
	tar zxf "ffmpeg-${FFMPEG_VERSION}.tar.gz" && rm "ffmpeg-${FFMPEG_VERSION}.tar.gz"

# Compile ffmpeg.
WORKDIR "/tmp/ffmpeg-${FFMPEG_VERSION}"
RUN ./configure --prefix="${PREFIX}" \
	--enable-gpl \
	--enable-version3 \
	--enable-nonfree \
	--enable-small \
	--enable-libmp3lame \
	--enable-libwebp \
	--enable-postproc \
	--disable-static \
	--enable-shared \
	--disable-debug \
	--enable-avresample \
	--enable-libass \
	--enable-libfdk-aac \
	--enable-libfreetype \
	--enable-libmp3lame \
	--enable-libopus \
	--enable-libtheora \
	--enable-libvorbis \
	--enable-libvpx \
	--enable-libx264 \
	--enable-libx265 \
	--enable-openssl \
	--disable-ffplay \
	--disable-doc \
	--extra-libs="-lpthread -lm"
RUN make
RUN make install
RUN make distclean

# Cleanup.
RUN rm -rf /var/cache/* /tmp/*

FROM debian:bullseye-slim
COPY --from=ffmpeg-builder /usr/local/ /usr/local/
COPY --from=nginx-builder /usr/local/nginx/ /usr/local/nginx/

# Add non-free repos
COPY ./sources.list /etc/apt/sources.list

# Install runtime deps
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y libssl-dev \
	libavcodec58 \
	libavdevice58 \
	libavfilter7 \
	libavformat58 \
	libavresample4 \
	libavutil56 \
	libc6 \
	libpostproc55 \
	libsdl2-2.0-0 \
	libswresample3 \
	libswscale5 \
	libfdk-aac2

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./hls.sh /opt/hls.sh
RUN mkdir -p /opt/data/hls
ADD static /www/static

ENV HTTP_PORT 80
ENV HTTPS_PORT 443
ENV RTMP_PORT 1935

EXPOSE 80
EXPOSE 1935
STOPSIGNAL SIGQUIT
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
