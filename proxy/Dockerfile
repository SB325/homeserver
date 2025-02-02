ARG SRC_IMG
ARG SRC_TAG
FROM ${SRC_IMG}:${SRC_TAG}

USER root
RUN apt-get -y update && apt-get -y upgrade
# RUN apt-get install -y apache2
#COPY certs/crunchy-dyndns.crt /etc/ssl/certs/crunchy-dyndns.crt
#COPY certs/crunchy-dyndns.key /etc/ssl/private/crunchy-dyndns.key
COPY nginx.conf /etc/nginx/nginx.conf