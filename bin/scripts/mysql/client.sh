#!/usr/bin/env bash

# 根据 def 中的定义格式化参数
parse_args_with_def "$@"

if [[ -z "$args_user" ]]; then
  log::error "请使用 --user 指定用户名"
  exit 1
fi

if [[ -z "$args_password" ]]; then
  log::error "请使用 --password 指定密码"
  exit 1
fi
if [[ -z "$args_port" ]]; then
  args_port="3306"
fi

echo "
# 常用命令
show databases;
use <database>;
show tables;
# 设置命令行的字符集, 仅在当前命令行生效, 不改动 mysql 全局配置
set character_set_client = utf8mb4;
set character_set_connection = utf8mb4;
set character_set_results = utf8mb4;
"

# 用 docker 作为客户端
# shellcheck disable=SC2154
docker run -it --rm mysql \
  mysql -h "$args_host" "-u$args_user" "-p$args_password" "-P$args_port"