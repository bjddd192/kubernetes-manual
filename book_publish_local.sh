#! /bin/bash

# 编译构建 gitbook
gitbook install
gitbook build
# 本地发布
gitbook serve
