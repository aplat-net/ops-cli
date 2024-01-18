#!/usr/bin/env bash

# 打印所有参数, 每个参数占一行
while [[ $# -gt 0 ]]; do
  echo "$1 ]]"
  shift
done


echo tst