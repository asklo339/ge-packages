#!/bin/bash
set -e

# packages/xorgproto/build.sh: Build script for xorgproto package

# Package metadata
PKG_NAME="xorgproto"
PKG_VERSION="2023.2"
PKG_DESCRIPTION="X11 protocol headers for Wine X11 support"
PKG_LICENSE="MIT"
PKG_SRC_URL="https://www.x.org/releases/individual/proto/xorgproto-${PKG_VERSION}.tar.gz"
PKG_SRC_FILE="$SOURCES_DIR/xorgproto-${PKG_VERSION}.tar.gz"
PKG_SRC_DIR="$BUILD_DIR/xorgproto/xorgproto-${PKG_VERSION}"
PKG_BUILD_DIR="$BUILD_DIR/xorgproto"

# Source environment
if [ -z "$PREFIX" ] || [ -z "$SOURCES_DIR" ] || [ -z "$BUILD_DIR" ]; then
    echo "Error: PREFIX, SOURCES_DIR, or BUILD_DIR not set. Source prop.sh first."
    exit 1
fi

# Download source
if [ ! -f "$PKG_SRC_FILE" ]; then
    echo "Downloading $PKG_NAME $PKG_VERSION..."
    mkdir -p "$SOURCES_DIR"
    if ! curl -L "$PKG_SRC_URL" -o "$PKG_SRC_FILE" && ! wget "$PKG_SRC_URL" -O "$PKG_SRC_FILE"; then
        echo "Error: Failed to download $PKG_NAME source"
        exit 1
    fi
fi

# Create build directory
mkdir -p "$PKG_BUILD_DIR"
 impedit 
# Extract source
if [ ! -d "$PKG_SRC_DIR" ]; then
    echo "Extracting $PKG_SRC_FILE..."
    tar -xzf "$PKG_SRC_FILE" || { echo "Error: Failed to extract $PKG_NAME source"; exit 1; }
fi

# Build
cd "$PKG_SRC_DIR"
echo "Configuring $PKG_NAME..."
export CC="$CC"
export CFLAGS="$CFLAGS"
export LDFLAGS="$LDFLAGS"
./configure --prefix="$PREFIX" || { echo "Error: Failed to configure $PKG_NAME"; exit 1; }

echo "Building $PKG_NAME..."
make -j"$MAKE_PROCESSES" || { echo "Error: Failed to build $PKG_NAME"; exit 1; }

# Install
echo "Installing $PKG_NAME to $PREFIX..."
make install || { echo "Error: Failed to install $PKG_NAME"; exit 1; }

# Verify installation
echo "Verifying $PKG_NAME installation..."
if [ -f "$PREFIX/include/X11/Xlib.h" ]; then
    echo "$PKG_NAME installed successfully at $PREFIX/include/X11/Xlib.h"
else
    echo "Error: $PKG_NAME not installed"
    exit 1
fi

# Copy to output
mkdir -p "$BUILD_TOPDIR/output/$PKG_NAME"
cp -r "$PREFIX/include/X11" "$BUILD_TOPDIR/output/$PKG_NAME/"
echo "$PKG_NAME $PKG_VERSION has been successfully installed at $PREFIX"
