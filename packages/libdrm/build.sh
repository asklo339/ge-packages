#!/bin/bash

# Source NDK setup
source ../../setup_ndk.sh

# Variables
LIBDRM_VERSION="2.4.120"  # Check latest at https://dri.freedesktop.org/libdrm/
LIBDRM_URL="https://dri.freedesktop.org/libdrm/libdrm-${LIBDRM_VERSION}.tar.xz"
INSTALL_PREFIX="/data/data/com.gebox.emu/files/usr/bionic"
BUILD_DIR="$(pwd)/build"
OUTPUT_DIR="$(pwd)/output"

# Download and extract libdrm
if [ ! -d "libdrm-${LIBDRM_VERSION}" ]; then
    echo "Downloading libdrm ${LIBDRM_VERSION}..."
    wget -q "$LIBDRM_URL"
    tar -xf "libdrm-${LIBDRM_VERSION}.tar.xz"
    rm "libdrm-${LIBDRM_VERSION}.tar.xz"
fi

# Apply patches if they exist
if [ -d "patches" ]; then
    cd "libdrm-${LIBDRM_VERSION}"
    for patch in ../patches/*.patch; do
        if [ -f "$patch" ]; then
            echo "Applying patch: $patch"
            patch -p1 < "$patch"
        fi
    done
    cd ..
fi

# Configure with Meson
cd "libdrm-${LIBDRM_VERSION}"
meson setup "$BUILD_DIR" \
    --cross-file ../../cross-android.txt \
    --prefix="$INSTALL_PREFIX" \
    -Ddefault_library=shared \
    -Dintel=disabled \
    -Dradeon=enabled \
    -Damdgpu=enabled \
    -Dnouveau=enabled \
    -Dvmwgfx=disabled \
    -Dtests=false

# Build and install
ninja -C "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"
ninja -C "$BUILD_DIR" install DESTDIR="$OUTPUT_DIR"

# Package the output
cd "$OUTPUT_DIR"
tar -czf "../../libdrm-rootfs.tar.gz" .
