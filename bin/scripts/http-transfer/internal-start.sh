#!/usr/bin/env bash

docker rm -f opscli-http-transfer-internal

mkdir -p "${WORKING_DIR}/.logs/http-transfer-internal"

# nginx.conf 参考 bin/data/http-transfer/example
docker run -d \
        -p 15778:443 \
        --name opscli-http-transfer-internal \
        -v "${WORKING_DIR}/bin/secret/http-transfer/nginx.internal.conf:/etc/nginx/nginx.conf" \
        -v "${WORKING_DIR}/.logs/http-transfer-internal:/var/log/nginx/" \
        -v "${WORKING_DIR}/bin/secret/certs/:/data/certs/" \
        nginx

