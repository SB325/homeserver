ARG SRC_IMG
ARG SRC_TAG
FROM ${SRC_IMG}:${SRC_TAG}

ARG PROXY_USER=${PROXY_USER}
ARG PROXY_PASSWORD=${PROXY_PASSWORD}
ARG MY_DNS_NAME=${MY_DNS_NAME}
ENV PROXY_USER=${PROXY_USER}
ENV PROXY_PASSWORD=${PROXY_PASSWORD}
ENV MY_DNS_NAME=${MY_DNS_NAME}

USER root
RUN apt-get update 
RUN apt-get -y install apache2-utils

# COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY ${TLS_CERT_FILE} /etc/ssl/certs/${TLS_CERT_FILE}

COPY index_mrapp.html /usr/share/nginx/html/

RUN htpasswd -b -c /etc/nginx/.htpasswd ${PROXY_USER} ${PROXY_PASSWORD}