#!/bin/bash
set -e

# Download and extract MinGW from the specific release
MINGW_URL="https://github.com/bylaws/llvm-mingw/releases/download/20250228/llvm-mingw-20250228-ucrt-ubuntu-20.04-x86_64.tar.xz"
wget "$MINGW_URL" -O /tmp/llvm-mingw.tar.xz
tar -xJf /tmp/llvm-mingw.tar.xz -C /opt
rm /tmp/llvm-mingw.tar.xz

# Set environment variable for MinGW path
export PATH="/opt/llvm-mingw-20250228-ucrt-ubuntu-20.04-x86_64/bin:$PATH"