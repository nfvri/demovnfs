FROM ubuntu:20.04
EXPOSE 8000/tcp 8001/tcp 8002/tcp
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt install -y gcc make git golang
RUN mkdir /go
ENV GOPATH /go
RUN go get github.com/nfvsap/simple-em
RUN git clone https://github.com/anastop/archbench 
RUN git clone https://github.com/anastop/util 
WORKDIR archbench/memory_tests 
RUN make
WORKDIR /
RUN echo "archbench/memory_tests/randacc \$1 2>&1 >/dev/null | /go/bin/simple-em" >> run.sh
CMD /bin/bash /run.sh 20
 
