ARG SRC_IMG
ARG SRC_TAG
FROM ${SRC_IMG}:${SRC_TAG}

ARG PROXY_USER
ARG PROXY_PASSWORD
ENV PROXY_USER=${PROXY_USER}
ENV PROXY_PASSWORD=${PROXY_PASSWORD}

USER root
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install apache2-utils

COPY nginx.conf /etc/nginx/nginx.conf
COPY index_mrapp.html /usr/share/nginx/html/

RUN htpasswd -b -c /etc/nginx/.htpasswd ${PROXY_USER} ${PROXY_PASSWORD}