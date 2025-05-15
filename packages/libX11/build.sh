#!/bin/bash
set -e

# packages/libX11/build.sh: Build script for libX11 package for Android ARM64

# Package metadata
PKG_NAME="libX11"
PKG_VERSION="1.8.7"
PKG_DESCRIPTION="X11 client-side library for Wine X11 support"
PKG_LICENSE="MIT"
PKG_SRC_URL="https://www.x.org/releases/individual/lib/libX11-${PKG_VERSION}.tar.gz"
PKG_SRC_FILE="$SOURCES_DIR/libX11-${PKG_VERSION}.tar.gz"
PKG_SRC_DIR="$BUILD_DIR/libX11/libX11-${PKG_VERSION}"

# Source environment
if [ -z "$PREFIX" ] || [ -z "$SOURCES_DIR" ] || [ -z "$BUILD_DIR" ] || [ -z "$BUILD_TOPDIR" ]; then
    echo "Error: PREFIX, SOURCES_DIR, BUILD_DIR, or BUILD_TOPDIR not set. Source prop.sh first."
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

# Create source directory
mkdir -p "$BUILD_DIR/libX11"

# Extract source
if [ ! -d "$PKG_SRC_DIR" ]; then
    echo "Extracting $PKG_SRC_FILE..."
    tar -xzf "$PKG_SRC_FILE" -C "$BUILD_DIR/libX11" || { echo "Error: Failed to extract $PKG_NAME source"; exit 1; }
fi

# Build
cd "$PKG_SRC_DIR"
echo "Configuring $PKG_NAME..."
export CC="$CC"
export CFLAGS="$CFLAGS -I$PREFIX/include -I$PREFIX/include/X11"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
./configure \
    --prefix="$PREFIX" \
    --host=aarch64-linux-android \
    --enable-static \
    --disable-shared \
    --x-includes="$PREFIX/include" \
    --x-libraries="$PREFIX/lib" \
    || { echo "Error: Failed to configure $PKG_NAME"; cat config.log; exit 1; }

echo "Building $PKG_NAME..."
make -j"$MAKE_PROCESSES" || { echo "Error: Failed to build $PKG_NAME"; exit 1; }

# Install
echo "Installing $PKG_NAME to $PREFIX..."
make install || { echo "Error: Failed to install $PKG_NAME"; exit 1; }

# Verify installation
echo "Verifying $PKG_NAME installation..."
if [ -f "$PREFIX/lib/libX11.a" ]; then
    echo "$PKG_NAME installed successfully at $PREFIX/lib/libX11.a"
else
    echo "Error: $PKG_NAME not installed"
    exit 1
fi

# Copy to output
mkdir -p "$BUILD_TOPDIR/output/$PKG_NAME"
cp -r "$PREFIX/lib/libX11.a" "$PREFIX/include/X11" "$BUILD_TOPDIR/output/$PKG_NAME/"
echo "$PKG_NAME $PKG_VERSION has been successfully installed at $PREFIX"
