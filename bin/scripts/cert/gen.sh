#!/usr/bin/env bash

CERT_EMAIL="$CERT_DEFAULT_EMAIL"
while [ -n "$1" ]; do
  if [[ "$1" == "--domain" || "$1" == "-d" ]]; then
    CERT_DOMAIN="$2"
    shift
  elif [[ "$1" == "--email" || "$1" == "-e" ]]; then
    CERT_EMAIL="$2"
    shift
  else
    log::error "无法解析参数 $1"
    exit 1
  fi
  shift
done

if [[ -z "$CERT_DOMAIN" ]]; then
  log::error "请指定 --domain 参数"
  exit 1
fi

function generate_https_cert() {
  log::info "开始生成证书"
  log::info "域名: $CERT_DOMAIN"
  log::info "邮箱: $CERT_EMAIL"
  local tmp_dir output_dir
  tmp_dir="$(pwd)/.tmp/$(date "+%Y%m%d_%H%M%S")"
  output_dir="$(pwd)/bin/data/certs"

  sudo docker run -it --rm --name certbot-dns-aliyun \
    -v "${tmp_dir}/etc/letsencrypt:/etc/letsencrypt" \
    -v "${tmp_dir}/var/lib/letsencrypt:/var/lib/letsencrypt" \
    -v "${tmp_dir}/var/log/letsencrypt:/var/log/letsencrypt" \
    -e ALIYUN_CLI_ACCESS_KEY_ID="$ALI_DNS_ACCESS_KEY_ID" \
    -e ALIYUN_CLI_ACCESS_KEY_SECRET="$ALI_DNS_ACCESS_KEY_SECRET" \
    aiyax/certbot-dns-aliyun certonly \
      -d "$CERT_DOMAIN" \
      --email "$CERT_EMAIL" \
      --manual \
      --non-interactive \
      --agree-tos \
      --preferred-challenges dns \
      --manual-auth-hook 'aliyun-dns' \
      --manual-cleanup-hook 'aliyun-dns clean'

  sudo chown -R "$(id -u):$(id -u)" "${tmp_dir}/"
  mkdir -p "${tmp_dir}/certs"
  mkdir -p "$output_dir"
  cp -rL "${tmp_dir}"/etc/letsencrypt/live/* "$output_dir"
  log::success "$CERT_DOMAIN 的证书已生成到 $output_dir 目录"
}

generate_https_cert