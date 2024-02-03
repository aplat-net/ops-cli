#!/usr/bin/env bash

# 根据 def 中的定义格式化参数
parse_args_with_def "$@"

if [[ -z "$args_name" ]]; then
  # shellcheck disable=SC2154
  args_name="mysql8_quick_start_${args_port}"
  log::info "docker 容器名称: ${args_name}"
fi


# shellcheck disable=SC2154
docker run -d \
  -p "${args_port}:3306" \
  -e "MYSQL_ROOT_PASSWORD=${args_password}" \
  -e MYSQL_ROOT_HOST='%' \
  -e TZ=Asia/Shanghai \
  --name "${args_name}" \
  mysql:8 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_general_ci \
  --explicit_defaults_for_timestamp=true \
  --lower_case_table_names=1 \
  --max_allowed_packet=128M \
  --default-authentication-plugin=caching_sha2_password

