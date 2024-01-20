#!/usr/bin/env bash

log::info "Hello, world!" "This is a test."
log::warn "Hello, world!" "This is a test."
log::error "Hello, world!" "This is a test."
log::success "Hello, world!" "This is a test."
log::debug "Hello, world!" "This is a test."
log::debug
log::trace "这是一个 trace log"

# sudo docker run hello-world

# sudo docker run ello-world
    read -r -p "测试一下, 请输入任意值
    " confirm_result
    echo "confirm_result=$confirm_result"

