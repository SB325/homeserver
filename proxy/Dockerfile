ARG SRC_IMG
ARG SRC_TAG
FROM ${SRC_IMG}:${SRC_TAG}

USER root
#COPY certs/crunchy-dyndns.crt /etc/ssl/certs/crunchy-dyndns.crt
#COPY certs/crunchy-dyndns.key /etc/ssl/private/crunchy-dyndns.key
COPY nginx.conf /etc/nginx/nginx.conf
