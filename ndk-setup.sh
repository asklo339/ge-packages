#!/bin/bash

NDK_VERSION="r26b"  # Adjust to latest if needed
NDK_URL="https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux.zip"
NDK_DIR="$HOME/android-ndk-${NDK_VERSION}"
TOOLCHAIN="$NDK_DIR/toolchains/llvm/prebuilt/linux-x86_64"

# Download and extract NDK
if [ ! -d "$NDK_DIR" ]; then
    echo "Downloading Android NDK ${NDK_VERSION}..."
    wget -q "$NDK_URL" -O ndk.zip
    unzip -q ndk.zip -d "$HOME"
    rm ndk.zip
fi

# Install Meson if not present
if ! command -v meson &> /dev/null; then
    echo "Installing Meson..."
    sudo apt-get update
    sudo apt-get install -y python3-pip
    pip3 install meson ninja
fi

# Export environment variables
export NDK_PATH="$NDK_DIR"
export PATH="$TOOLCHAIN/bin:$PATH"
export SYSROOT="$NDK_PATH/sysroot"
export CC="aarch64-linux-android21-clang"
export CXX="aarch64-linux-android21-clang++"
export AR="llvm-ar"
export LD="ld"
export CFLAGS="-fPIC -I$SYSROOT/usr/include -I$SYSROOT/usr/include/aarch64-linux-android"
export LDFLAGS="-L$SYSROOT/usr/lib/aarch64-linux-android/21"

echo "NDK and Meson setup complete."
