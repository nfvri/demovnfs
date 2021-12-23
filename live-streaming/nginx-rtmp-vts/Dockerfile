FROM debian:bullseye AS builder
COPY . /code
RUN apt-get update
RUN apt-get upgrade
RUN apt-get install -y build-essential make wget libpcre3-dev \
	libssl-dev zlib1g-dev
RUN make -C /code
RUN make -C /code install

FROM debian:bullseye-slim
COPY --from=builder /usr/local/nginx/ /usr/local/nginx/
COPY ./nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /opt/data/hls

EXPOSE 80
STOPSIGNAL SIGQUIT
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
