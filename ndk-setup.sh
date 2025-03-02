#!/bin/bash
set -e

# Download and install NDK r26b
NDK_VERSION="r26b"
NDK_URL="https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux.zip"
wget "$NDK_URL" -O /tmp/android-ndk.zip
unzip /tmp/android-ndk.zip -d /opt
rm /tmp/android-ndk.zip

# Set environment variables
export ANDROID_NDK_HOME="/opt/android-ndk-${NDK_VERSION}"
export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"