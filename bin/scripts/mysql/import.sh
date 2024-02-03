#!/usr/bin/env bash

# 根据 def 中的定义格式化参数
parse_args_with_def "$@"

if [[ -z "$args_password" ]]; then
  log::error "请使用 --password 指定密码"
  exit 1
fi

if [[ -z "$args_database" ]]; then
  log::error "请使用 --database 指定数据库"
  exit 1
fi

# shellcheck disable=SC2154
if [[ $args_pos_args_length -eq 0 ]]; then
  log::error "请指定备份文件"
  exit 1
fi

if [[ $args_pos_args_length -gt 1 ]]; then
  log::error "只能指定一个备份文件"
  exit 1
fi

# 获取相对执行目录的绝对路径
# shellcheck disable=SC2154
DUMP_FILE="$(realpath "$PREVIOUS_DIR/$args_pos_args_0")"
if [[ ! -f "$DUMP_FILE" ]]; then
  log::error "备份文件不存在: $DUMP_FILE"
  exit 1
fi

DUMP_TEMP_DIR="$(mktemp -d)"
log::debug "创建临时目录: $DUMP_TEMP_DIR"

cp "$DUMP_FILE" "${DUMP_TEMP_DIR}/data.sql"


# shellcheck disable=SC2154
log::warn "${COLOR_YELLOW}是否确认将 $DUMP_FILE 导入到 $args_host:$args_port $args_database ? [y/N] ${COLOR_NONE}"
read -r -p "" confirm_result
if [[ "$confirm_result" != "y" ]]; then
  log::info "已取消"
  exit 1
fi

# 生成脚本文件
# shellcheck disable=SC2154
echo "
mysql -h $args_host -u$args_user -p$args_password -P$args_port $args_database < /data/data.sql 
" > "$DUMP_TEMP_DIR/entrypoint.sh"

# 用 docker 作为客户端
# shellcheck disable=SC2154
docker run -it --rm \
  -v "${DUMP_TEMP_DIR}:/data" \
  mysql \
  bash /data/entrypoint.sh

