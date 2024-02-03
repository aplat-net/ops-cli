#!/usr/bin/env bash

mkdir -p "logs"

LOG_FILE_PATH="logs/opscli.$(date "+%Y%m%d").log"

function log::output() {
  echo -e "$(date "+%Y-%m-%dT%H:%M:%S") $*"
}

function log::info() {
  log::output "${COLOR_BLUE}[INFO]${COLOR_NONE} $*"
}

function log::warn() {
  log::output "${COLOR_YELLOW}[WARN]${COLOR_NONE} $*"
}

function log::error() {
  log::output "${COLOR_RED}[ERROR]${COLOR_NONE} $*"
}

# 在 ./opscli 文件中, 会使用 tee 将输出输出到日志文件中, 但是 debug 的不会输出到终端, 所以需要单独写入日志文件
function log::debug() {
  log::output "${COLOR_GRAY}[DEBUG]${COLOR_NONE} $*" >> "$LOG_FILE_PATH"
  if [[ "$OPS_CLI_DEBUG" == "true" ]]; then
    log::output "${COLOR_GRAY}[DEBUG]${COLOR_NONE} $*"
  fi
}
# trace 只会写入日志文件, 不会写入终端
function log::trace() {
  local caller_i caller_output
  log::output "${COLOR_GRAY}[TRACE]${COLOR_NONE} $*" >> "$LOG_FILE_PATH"
  # 最后一个 caller 会导致程序异常退出, 所以这里添加一个 set +e, 执行完 caller 之后再 set -e
  set +e
  caller_i=0
  while true; do
    caller_output="$(caller $caller_i)"
    if [[ -n "$caller_output" ]]; then
      log::output "${COLOR_GRAY}[TRACE]${COLOR_NONE} $caller_output" >> "$LOG_FILE_PATH"
      caller_i=$((caller_i+1))
    else
      break
    fi
  done
  set -e
}

function log::success() {
  log::output "${COLOR_GREEN}[SUCCESS]${COLOR_NONE} $*"
}