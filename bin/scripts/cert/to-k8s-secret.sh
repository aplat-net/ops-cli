#!/usr/bin/env bash

# 根据 def 中的定义格式化参数
parse_args_with_def "$@"


if [[ -z "$args_namespace" ]]; then
  log::error "请指定 --namespace"
  exit 1
fi

if [[ -z "$args_secret" ]]; then
  log::error "请指定 --secret"
  exit 1
fi

# shellcheck disable=SC2154
if [[ $args_pos_args_length -eq 0 ]]; then
  log::error "请指定域名"
  exit 1
fi

if [[ $args_pos_args_length -gt 1 ]]; then
  log::error "只能指定一个域名"
  exit 1
fi

# shellcheck disable=SC2154
if [[ ! -f "$args_path/${args_pos_args_0}/$args_key" ]]; then
  log::error "私钥文件不存在: $args_path/${args_pos_args_0}/$args_key"
  exit 1
fi

# shellcheck disable=SC2154
if [[ ! -f "$args_path/${args_pos_args_0}/$args_cert" ]]; then
  log::error "证书文件不存在: $args_path/${args_pos_args_0}/$args_cert"
  exit 1
fi

# kubectl -n "$args_namespace" create secret tls "$args_secret" \
#   --key "$args_path/${args_pos_args_0}/$args_key" \
#   --cert "$args_path/${args_pos_args_0}/$args_cert"

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $args_secret
  namespace: $args_namespace
type: kubernetes.io/tls
data:
  tls.crt: $(base64 -w0 "$args_path/${args_pos_args_0}/$args_cert")
  tls.key: $(base64 -w0 "$args_path/${args_pos_args_0}/$args_key")
EOF

