#!/bin/bash

# Check if package name is provided
if [ -z "$1" ]; then
    echo "Error: No package specified. Usage: ./build.sh <package_name>"
    exit 1
fi

PACKAGE="$1"

echo "Starting build process for $PACKAGE..."
if [ -d "packages/$PACKAGE" ]; then
    cd "packages/$PACKAGE"
    ./build.sh
    cd ../..
    echo "Build complete. Output: ${PACKAGE}-rootfs.tar.gz"
else
    echo "Error: Package '$PACKAGE' not found in packages/"
    exit 1
fi
