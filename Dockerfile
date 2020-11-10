FROM alpine
RUN apk add --no-cache curl gzip coreutils bash
RUN curl -L -O https://github.com/BurntSushi/xsv/releases/download/0.13.0/xsv-0.13.0-x86_64-unknown-linux-musl.tar.gz
RUN gzip -d xsv-0.13.0-x86_64-unknown-linux-musl.tar.gz
RUN tar -xvf xsv-0.13.0-x86_64-unknown-linux-musl.tar
RUN cp xsv /usr/bin
COPY . .
CMD ./download.sh