FROM debian:buster

RUN apt-get update
RUN apt-get install -y libcurl4-openssl-dev libcrypto++-dev libssl-dev \
	git make build-essential

RUN git clone https://github.com/selsta/hlsdl /opt/hlsdl

RUN cd /opt/hlsdl && \
	make && \
	make install && \
	make clean
COPY stream.sh /usr/bin/stream

ENTRYPOINT ["stream"]
