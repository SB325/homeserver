ARG SRC_IMG
ARG SRC_TAG
FROM ${SRC_IMG}:${SRC_TAG}

USER root
RUN apt-get -y update && apt-get -y upgrade

COPY nginx.conf /etc/nginx/nginx.conf
COPY index_mrapp.html /usr/share/nginx/html/

# ENTRYPOINT ["tail", "-f", "/dev/null"]