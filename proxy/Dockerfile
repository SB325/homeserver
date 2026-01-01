ARG SRC_IMG
ARG SRC_TAG
FROM ${SRC_IMG}:${SRC_TAG}

ARG PROXY_USER
ARG PROXY_PASSWORD
ENV PROXY_USER=${PROXY_USER}
ENV PROXY_PASSWORD=${PROXY_PASSWORD}

USER root
RUN apt-get update 
RUN apt-get -y install apache2-utils

COPY nginx.conf /etc/nginx/nginx.conf
COPY crunchy.dyndns.org.crt /etc/ssl/certs/crunchy.dyndns.org.crt
COPY crunchy.dyndns.org.key /etc/ssl/private/crunchy.dyndns.org.key

COPY index_mrapp.html /usr/share/nginx/html/

RUN htpasswd -b -c /etc/nginx/.htpasswd ${PROXY_USER} ${PROXY_PASSWORD}