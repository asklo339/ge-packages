#!/bin/bash
set -e

CROSS_FILE=$1
INSTALL_ROOT=$2
TOOLCHAIN=$3
USE_MINGW=$4  # Optional flag to force MinGW

# Determine toolchain
if [ "$USE_MINGW" = "mingw" ]; then
    echo "Using MinGW toolchain explicitly"
    export PATH="$TOOLCHAIN:$PATH"
    COMPILER_PREFIX="x86_64-w64-mingw32"
elif [ -z "$USE_MINGW" ] && echo "$CROSS_FILE" | grep -q "windows"; then
    echo "Defaulting to MinGW for Windows target"
    export PATH="$TOOLCHAIN:$PATH"
    COMPILER_PREFIX="x86_64-w64-mingw32"
else
    echo "Using NDK toolchain for Android"
    export PATH="$TOOLCHAIN:$PATH"
    COMPILER_PREFIX="aarch64-linux-android"
fi

# Download libdrm source
LIBDRM_VERSION="2.4.124"
LIBDRM_URL="https://dri.freedesktop.org/libdrm/libdrm-${LIBDRM_VERSION}.tar.xz"
LIBDRM_TAR="libdrm-${LIBDRM_VERSION}.tar.xz"
LIBDRM_DIR="libdrm-${LIBDRM_VERSION}"

echo "Downloading libdrm ${LIBDRM_VERSION} from ${LIBDRM_URL}"
wget -O "$LIBDRM_TAR" "$LIBDRM_URL"

# Extract the source
echo "Extracting $LIBDRM_TAR"
tar -xJf "$LIBDRM_TAR"
cd "$LIBDRM_DIR"

# Meson setup with target-specific options
# Adjust the CROSS_FILE path to be absolute from /build
MESON_OPTS="--prefix=$INSTALL_ROOT --cross-file=/build/$(basename "$CROSS_FILE")"
if echo "$CROSS_FILE" | grep -q "windows"; then
    # Windows: Disable X11 and other Linux-specific features
    MESON_OPTS="$MESON_OPTS -Dintel=disabled -Dradeon=disabled -Damdgpu=disabled -Dnouveau=disabled -Dvmwgfx=disabled"
else
    # Android: Enable relevant drivers (e.g., freedreno for Qualcomm GPUs)
    MESON_OPTS="$MESON_OPTS -Dintel=disabled -Dradeon=disabled -Damdgpu=disabled -Dnouveau=disabled -Dvmwgfx=disabled -Dfreedreno=enabled"
fi

# Configure with Meson
echo "Configuring libdrm with Meson"
CFLAGS="${CFLAGS} -DANDROID" meson setup build $MESON_OPTS

# Build and install
echo "Building and installing libdrm"
ninja -C build
DESTDIR="$INSTALL_ROOT" ninja -C build install

echo "Built and installed libdrm into $INSTALL_ROOT"
