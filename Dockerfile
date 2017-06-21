FROM alpine
MAINTAINER Michael Clayton <mclayton@redhat.com>

ENV LANG en_US.utf8

RUN apk update
RUN apk add varnish curl

ADD alpine-varnish.tar.gz /

ENTRYPOINT ["/usr/local/bin/start"]
