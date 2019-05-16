FROM ubuntu:16.04
EXPOSE 8000/tcp 8001/tcp 8002/tcp
RUN apt-get update
RUN apt-get install -y gcc make git golang
RUN mkdir /go
ENV GOPATH /go
RUN go get github.com/nfvsap/simple-em
RUN git clone https://github.com/anastop/archbench 
RUN git clone https://github.com/anastop/util 
WORKDIR archbench/memory_tests 
RUN make
WORKDIR /
RUN echo "archbench/memory_tests/seqacc 150 &" > run.sh
RUN echo "archbench/memory_tests/seqacc 150 &" >> run.sh
RUN echo "archbench/memory_tests/seqacc 150 &" >> run.sh
RUN echo "archbench/memory_tests/seqacc 150 &" >> run.sh
RUN echo "archbench/memory_tests/seqacc 150 &" >> run.sh
RUN echo "archbench/memory_tests/seqacc 150 &" >> run.sh
RUN echo "archbench/memory_tests/seqacc 150 &" >> run.sh
RUN echo "archbench/memory_tests/seqacc 150 2>&1 >/dev/null | /go/bin/simple-em" >> run.sh
CMD /bin/bash /run.sh
 
