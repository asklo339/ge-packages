#!/bin/bash

NDK_VERSION="r26b"
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

# Install Meson and Ninja
if ! command -v meson &> /dev/null; then
    echo "Installing Meson and Ninja..."
    sudo apt-get update
    sudo apt-get install -y python3-pip
    pip3 install meson ninja
fi

# Export environment variables
export NDK_PATH="$NDK_DIR"
export PATH="$TOOLCHAIN/bin:$PATH"
export SYSROOT="$NDK_PATH/sysroot"

echo "NDK setup complete."
