#!/bin/bash
# prop.sh: Defines build environment variables

# Base directory for build environment
export BUILD_TOPDIR="$HOME/.package-builder"

# Android NDK path (downloaded)
export NDK="$BUILD_TOPDIR/ndk/android-ndk-r27c"

# Sources directory for downloaded packages
export SOURCES_DIR="$BUILD_TOPDIR/sources"

# Build directory for compilation
export BUILD_DIR="$BUILD_TOPDIR/build"

# Android API level
export API_LEVEL=33

# Installation prefix
export PREFIX="/data/data/com.gebox.emu/files/usr/bionic"

# Default architecture
export ARCH="arm64-v8a"

# Map architecture to NDK target
case "$ARCH" in
    arm64-v8a)
        export TARGET="aarch64-linux-android"
        export ARCH_BITS=64
        ;;
    armeabi-v7a)
        export TARGET="armv7a-linux-androideabi"
        export ARCH_BITS=32
        ;;
    x86)
        export TARGET="i686-linux-android"
        export ARCH_BITS=32
        ;;
    x86_64)
        export TARGET="x86_64-linux-android"
        export ARCH_BITS=64
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# NDK toolchain paths
export TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/linux-x86_64"
export SYSROOT="$TOOLCHAIN/sysroot"
export CC="$TOOLCHAIN/bin/$TARGET$API_LEVEL-clang"
export CXX="$TOOLCHAIN/bin/$TARGET$API_LEVEL-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export STRIP="$TOOLCHAIN/bin/llvm-strip"
export READELF="$TOOLCHAIN/bin/llvm-readelf"

# Compiler flags
export CFLAGS="-I$PREFIX/include -I$SYSROOT/usr/include -fPIC"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
# Baseline LDFLAGS with Android libraries
export LDFLAGS="-L$PREFIX/lib -L$SYSROOT/usr/lib/$TARGET/$API_LEVEL -llog"

# Pkg-config paths
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"

# Number of make jobs
export MAKE_PROCESSES=$(nproc)

# Package builder maintainer
export MAINTAINER="Your Name <your.email@example.com>"
