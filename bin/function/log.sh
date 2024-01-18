#!/usr/bin/env bash

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

function log::debug() {
  if [[ "$OPS_CLI_DEBUG" != "true" ]]; then
    return
  fi
  log::output "${COLOR_GRAY}[DEBUG]${COLOR_NONE} $*"
  local i=0
  while caller $i; do
      i=$((i+1))
  done
}

function log::success() {
  log::output "${COLOR_GREEN}[SUCCESS]${COLOR_NONE} $*"
}