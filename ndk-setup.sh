#!/bin/bash
set -e

# ndk-setup.sh
# Downloads and sets up the Android NDK.
NDK_VERSION="r26b"
NDK_ZIP="android-ndk-${NDK_VERSION}-linux.zip"
NDK_DIR="/opt/android-ndk-${NDK_VERSION}"

if [ ! -d "${NDK_DIR}" ]; then
    echo "Downloading Android NDK ${NDK_VERSION}..."
    wget https://dl.google.com/android/repository/${NDK_ZIP} -O /tmp/${NDK_ZIP}
    unzip /tmp/${NDK_ZIP} -d /opt
    rm /tmp/${NDK_ZIP}
fi

export ANDROID_NDK="${NDK_DIR}"
echo "ANDROID_NDK is set to ${ANDROID_NDK}"
