#!/usr/bin/env bash

# 根据 def 中的定义格式化参数
parse_args_with_def "$@"

if [[ -z "$args_password" ]]; then
  log::error "请使用 --password 指定密码"
  exit 1
fi

# shellcheck disable=SC2154
if [[ $args_pos_args_length -eq 0 ]]; then
  log::error "请输入数据库名称"
  exit 1
fi

if [[ $args_pos_args_length -gt 1 ]]; then
  log::error "只能输入一个数据库名称"
  exit 1
fi

DUMP_TEMP_DIR="$(mktemp -d)"
log::debug "创建临时目录: $DUMP_TEMP_DIR"

# 生成脚本文件
# shellcheck disable=SC2154
echo "
mysql -h $args_host -u$args_user -p$args_password -P$args_port \\
  -e 'CREATE DATABASE $args_pos_args_0 DEFAULT CHARACTER SET utf8mb4;'
" > "$DUMP_TEMP_DIR/entrypoint.sh"

# 用 docker 作为客户端
# shellcheck disable=SC2154
docker run -it --rm \
  -v "${DUMP_TEMP_DIR}:/data" \
  mysql \
  bash /data/entrypoint.sh

