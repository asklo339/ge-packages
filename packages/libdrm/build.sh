#!/bin/bash
set -e

# packages/libdrm/build.sh
# This script builds libdrm using the Meson build system.
#
# It applies any available patches, configures the build with Meson,
# compiles using ninja, and installs libdrm to the CUSTOM_PREFIX directory.
#
# Environment Variables:
#   CUSTOM_PREFIX - The target installation prefix (e.g., /data/data/com.gebox.emu/files/usr/bionic)
#   ANDROID_NDK   - (Optional) The path to the Android NDK if required.

echo "Starting build for libdrm using Meson..."

# Ensure the CUSTOM_PREFIX is set, default if not.
if [ -z "${CUSTOM_PREFIX}" ]; then
  echo "CUSTOM_PREFIX not set; defaulting to /data/data/com.gebox.emu/files/usr/bionic"
  CUSTOM_PREFIX="/data/data/com.gebox.emu/files/usr/bionic"
fi
export CUSTOM_PREFIX
echo "Installation prefix: ${CUSTOM_PREFIX}"

# Optionally apply patches if any exist in the patches/ directory.
if [ -d ../patches ]; then
  echo "Applying patches..."
  for patch in ../patches/*.patch; do
    if [ -f "$patch" ]; then
      echo "Applying patch: $patch"
      patch -p1 < "$patch"
    fi
  done
fi

# Create and move into a separate build directory.
mkdir -p build && cd build

# Configure the build with Meson.
# You can pass additional parameters if necessary (e.g., toolchain files for cross-compilation).
echo "Configuring libdrm with Meson..."
meson setup --prefix="${CUSTOM_PREFIX}" --buildtype=release ..

# Build the project using Ninja.
echo "Building libdrm..."
ninja -j$(nproc)

# Install the project into the CUSTOM_PREFIX.
echo "Installing libdrm to ${CUSTOM_PREFIX}..."
ninja install

echo "libdrm build and installation complete."
