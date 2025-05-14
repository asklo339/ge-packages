#!/bin/bash
set -e

# build.sh: Main package builder script

# Usage
usage() {
    echo "Usage: $0 [-a arch] [-f] [package_name | all]"
    echo "Options:"
    echo "  -a arch    Architecture (arm64-v8a, armeabi-v7a, x86, x86_64)"
    echo "  -f         Force rebuild even if package exists"
    echo "  package_name  Build a specific package"
    echo "  all        Build all packages"
    exit 1
}

# Parse arguments
FORCE_BUILD=false
while getopts "a:f" opt; do
    case $opt in
        a) ARCH="$OPTARG" ;;
        f) FORCE_BUILD=true ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))

# Package name or 'all'
PACKAGE="$1"

# Source environment
if [ ! -f "prop.sh" ]; then
    echo "Error: prop.sh not found"
    exit 1
fi
source ./prop.sh

# Setup NDK
setup_ndk() {
    local ndk_version="r26d"
    local ndk_url="https://dl.google.com/android/repository/android-ndk-${ndk_version}-linux.zip"
    local ndk_zip="$BUILD_TOPDIR/ndk/android-ndk-${ndk_version}.zip"
    local ndk_dir="$BUILD_TOPDIR/ndk"

    if [ -d "$NDK" ]; then
        echo "NDK found at $NDK"
        return 0
    fi

    echo "Downloading NDK $ndk_version..."
    mkdir -p "$ndk_dir"
    if ! curl -L "$ndk_url" -o "$ndk_zip" && ! wget "$ndk_url" -O "$ndk_zip"; then
        echo "Error: Failed to download NDK"
        exit 1
    fi

    echo "Extracting NDK..."
    unzip -q "$ndk_zip" -d "$ndk_dir" || { echo "Error: Failed to extract NDK"; exit 1; }
    rm -f "$ndk_zip"

    if [ ! -d "$NDK" ]; then
        echo "Error: NDK setup failed, directory $NDK not found"
        exit 1
    fi
    echo "NDK setup complete at $NDK"
}

# Setup sources directory
setup_sources() {
    mkdir -p "$SOURCES_DIR"
    echo "Sources directory created at $SOURCES_DIR"
}

# Build a single package
build_package() {
    local pkg="$1"
    local pkg_dir="packages/$pkg"
    local build_script="$pkg_dir/build.sh"

    if [ ! -d "$pkg_dir" ]; then
        echo "Error: Package $pkg not found in packages/"
        return 1
    fi

    if [ ! -f "$build_script" ]; then
        echo "Error: build.sh not found in $pkg_dir"
        return 1
    }

    # Check if package is already built (example: check for a binary or lib)
    if [ -f "$PREFIX/bin/$pkg" ] || [ -f "$PREFIX/lib/lib$pkg.so" ] && [ "$FORCE_BUILD" = false ]; then
        echo "Package $pkg already installed at $PREFIX, skipping (use -f to force)"
        return 0
    }

    echo "Building package $pkg..."
    cd "$pkg_dir"
    bash build.sh || { echo "Failed to build $pkg"; exit 1; }
    cd ../..
    echo "Package $pkg built successfully"
}

# Build all packages
build_all() {
    echo "Building all packages..."
    for pkg_dir in packages/*; do
        if [ -d "$pkg_dir" ]; then
            pkg=$(basename "$pkg_dir")
            build_package "$pkg"
        fi
    done
    echo "All packages built successfully"
}

# Main logic
setup_ndk
setup_sources

if [ -z "$PACKAGE" ]; then
    usage
elif [ "$PACKAGE" = "all" ]; then
    build_all
else
    build_package "$PACKAGE"
fi
