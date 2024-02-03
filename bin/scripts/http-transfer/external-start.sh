#!/usr/bin/env bash

docker rm -f opscli-http-transfer-external

mkdir -p "${WORKING_DIR}/logs/http-transfer-external"

# nginx.conf 参考 bin/data/http-transfer/example
docker run -d \
        -p 80:80 \
        -p 443:443 \
        --name opscli-http-transfer-external \
        -v "${WORKING_DIR}/bin/secret/http-transfer/nginx.external.conf:/etc/nginx/nginx.conf" \
        -v "${WORKING_DIR}/logs/http-transfer-external:/var/log/nginx/" \
        -v "${WORKING_DIR}/bin/secret/certs/:/data/certs/" \
        nginx

