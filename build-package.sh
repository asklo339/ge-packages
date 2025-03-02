#!/bin/bash
set -e

# build-package.sh
# Usage: ./build-package.sh <package-name>
# This script sets up the environment and builds the specified package.

# Set custom prefix if not already defined.
CUSTOM_PREFIX=${CUSTOM_PREFIX:-"/data/data/com.gebox.emu/files/usr/bionic"}
export CUSTOM_PREFIX
echo "Custom install prefix set to: ${CUSTOM_PREFIX}"

# Run the Android NDK setup script.
if [ -x "./ndk-setup.sh" ]; then
    echo "Running Android NDK setup..."
    ./ndk-setup.sh
else
    echo "Warning: ndk-setup.sh not found or not executable."
fi

# Run the mingw setup script.
if [ -x "./mingw-setup.sh" ]; then
    echo "Running mingw setup..."
    ./mingw-setup.sh
else
    echo "Skipping mingw setup (script not found or not executable)."
fi

# Run download-deps.sh if available.
if [ -x "./download-deps.sh" ]; then
    echo "Downloading dependencies..."
    ./download-deps.sh
else
    echo "Skipping download-deps.sh (script not found or not executable)."
fi

# Run build-rootfs.sh if available.
if [ -x "./build-rootfs.sh" ]; then
    echo "Building root filesystem..."
    ./build-rootfs.sh
else
    echo "Skipping build-rootfs.sh (script not found or not executable)."
fi

# Check that a package name is provided.
if [ -z "$1" ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi

PACKAGE_NAME="$1"
PACKAGE_DIR="./packages/${PACKAGE_NAME}"

# Verify that the package directory exists.
if [ ! -d "${PACKAGE_DIR}" ]; then
    echo "Error: Package '${PACKAGE_NAME}' not found under packages/ directory."
    exit 1
fi

echo "Starting build for package: ${PACKAGE_NAME}"
cd "${PACKAGE_DIR}"

# Run the package's build script.
if [ -x "./build.sh" ]; then
    ./build.sh
else
    echo "Error: build.sh not found or not executable in ${PACKAGE_DIR}"
    exit 1
fi

echo "Package '${PACKAGE_NAME}' built successfully and installed to ${CUSTOM_PREFIX}"
