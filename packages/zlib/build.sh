#!/bin/bash
set -e

# packages/zlib/build.sh: Build script for zlib package

# Package metadata
PKG_NAME="zlib"
PKG_VERSION="1.3.1"
PKG_DESCRIPTION="Compression library for Android"
PKG_LICENSE="Zlib"
PKG_SRC_URL="https://zlib.net/zlib-${PKG_VERSION}.tar.gz"
PKG_SRC_FILE="$SOURCES_DIR/zlib-${PKG_VERSION}.tar.gz"
PKG_SRC_DIR="zlib-${PKG_VERSION}"

# Source environment
if [ -z "$PREFIX" ] || [ -z "$SOURCES_DIR" ]; then
    echo "Error: PREFIX or SOURCES_DIR not set. Source prop.sh first."
    exit 1
fi

# Create build directory
mkdir -p build
cd build

# Download source
if [ ! -f "$PKG_SRC_FILE" ]; then
    echo "Downloading $PKG_NAME $PKG_VERSION..."
    if ! curl -L "$PKG_SRC_URL" -o "$PKG_SRC_FILE" && ! wget "$PKG_SRC_URL" -O "$PKG_SRC_FILE"; then
        echo "Error: Failed to download $PKG_NAME source"
        exit 1
    fi
fi

# Extract source
if [ ! -d "$PKG_SRC_DIR" ]; then
    echo "Extracting $PKG_SRC_FILE..."
    tar -xzf "$PKG_SRC_FILE" || { echo "Error: Failed to extract $PKG_NAME source"; exit 1; }
fi

# Build
cd "$PKG_SRC_DIR"
echo "Configuring $PKG_NAME..."
./configure \
    --prefix="$PREFIX" \
    --static \
    CC="$CC" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" || { echo "Error: Failed to configure $PKG_NAME"; exit 1; }

echo "Building $PKG_NAME..."
make -j"$MAKE_PROCESSES" || { echo "Error: Failed to build $PKG_NAME"; exit 1; }

# Install
echo "Installing $PKG_NAME to $PREFIX..."
make install || { echo "Error: Failed to install $PKG_NAME"; exit 1; }

# Verify installation
echo "Verifying $PKG_NAME installation..."
if [ -f "$PREFIX/lib/libz.a" ]; then
    echo "$PKG_NAME installed successfully at $PREFIX/lib/libz.a"
else
    echo "Error: $PKG_NAME not installed"
    exit 1
fi

# Copy to output
cd ../..
mkdir -p "../../output/$PKG_NAME"
cp -r "$PREFIX/lib/libz.a" "$PREFIX/include/zlib.h" "$PREFIX/include/zconf.h" "../../output/$PKG_NAME/"
echo "$PKG_NAME $PKG_VERSION has been successfully installed at $PREFIX"
