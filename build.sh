#!/bin/bash

# Check if package name is provided
if [ -z "$1" ]; then
    echo "Error: No package specified. Usage: ./build.sh <package_name>"
    exit 1
fi

PACKAGE="$1"

echo "Starting build process for $PACKAGE..."
echo "Current directory: $(pwd)"  # Debug: Show working directory
if [ -d "packages/$PACKAGE" ]; then
    # Verify cross-android.txt exists
    if [ ! -f "cross-android.txt" ]; then
        echo "Error: cross-android.txt not found in root directory!"
        exit 1
    else
        echo "Found cross-android.txt in $(pwd)"
    fi
    cd "packages/$PACKAGE"
    ./build.sh
    cd ../..
    echo "Build complete. Output: ${PACKAGE}-rootfs.tar.gz"
else
    echo "Error: Package '$PACKAGE' not found in packages/"
    exit 1
fi
