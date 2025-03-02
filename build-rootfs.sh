#!/bin/bash
set -e

TARGET=$1
case "$TARGET" in
    android-aarch64)
        CROSS_FILE=../meson-cross-file-android-aarch64
        TOOLCHAIN="/opt/android-ndk-r26b/toolchains/llvm/prebuilt/linux-x86_64/bin"
        ;;
    windows-x86_64)
        CROSS_FILE=../meson-cross-file-windows-x86_64
        TOOLCHAIN="/opt/llvm-mingw-20250228-ucrt-ubuntu-20.04-x86_64/bin"
        ;;
    *)
        echo "Usage: $0 {android-aarch64|windows-x86_64}"
        exit 1
        ;;
esac

# Set up the installation root directory
INSTALL_ROOT="$PWD/data/data/com.gebox.emu/files/usr/bionic"
mkdir -p "$INSTALL_ROOT"

# Build each package
chmod +x build.sh
for pkg in packages/*; do
    if [ -d "$pkg" ] && [ -f "$pkg/build.sh" ]; then
        pkg_name=$(basename "$pkg")
        echo "Building $pkg_name for $TARGET"
        if [ "$TARGET" = "windows-x86_64" ] && [ "$pkg_name" = "example-package" ]; then
            (cd "$pkg" && ./build.sh "$CROSS_FILE" "$INSTALL_ROOT" "$TOOLCHAIN" "mingw")
        else
            (cd "$pkg" && ./build.sh "$CROSS_FILE" "$INSTALL_ROOT" "$TOOLCHAIN")
        fi
    fi
done

echo "Root filesystem built for $TARGET in $INSTALL_ROOT"
