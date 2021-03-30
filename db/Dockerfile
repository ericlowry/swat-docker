FROM couchdb:3.1

RUN apt-get update && apt-get install -y jq apache2-utils

COPY ./dev.ini /opt/couchdb/etc/local.d/dev.ini

COPY ./bin /dev/bin

ENV PATH="/dev/bin:${PATH}"
