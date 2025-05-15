#!/bin/bash
set -e

# packages/xorgproto/build.sh: Build script for xorgproto package using Autotools

# Package metadata
PKG_NAME="xorgproto"
PKG_VERSION="2023.2"
PKG_DESCRIPTION="X11 protocol headers for Wine X11 support"
PKG_LICENSE="MIT"
PKG_SRC_URL="https://www.x.org/releases/individual/proto/xorgproto-${PKG_VERSION}.tar.gz"
PKG_SRC_FILE="$SOURCES_DIR/xorgproto-${PKG_VERSION}.tar.gz"
PKG_SRC_DIR="$BUILD_DIR/xorgproto/xorgproto-${PKG_VERSION}"
PKG_PATCH_FILE="$PATCHES_DIR/xorgproto-android.patch"

# Source environment
if [ -z "$PREFIX" ] || [ -z "$SOURCES_DIR" ] || [ -z "$BUILD_DIR" ] || [ -z "$BUILD_TOPDIR" ]; then
    echo "Error: PREFIX, SOURCES_DIR, BUILD_DIR, or BUILD_TOPDIR not set. Source prop.sh first."
    exit 1
fi

# Create directories
mkdir -p "$SOURCES_DIR" "$BUILD_DIR/xorgproto"

# Define patches directory if not set
PATCHES_DIR="${PATCHES_DIR:-$BUILD_TOPDIR/patches}"
mkdir -p "$PATCHES_DIR"

# Create patch file from the provided diff
if [ ! -f "$PKG_PATCH_FILE" ]; then
    echo "Creating Android patch file for xorgproto..."
    cat > "$PKG_PATCH_FILE" << 'EOF'
diff -uNr xorgproto-2019.1/include/X11/Xos_r.h xorgproto-2019.1.mod/include/X11/Xos_r.h
--- xorgproto-2019.1/include/X11/Xos_r.h	2019-06-20 06:13:03.000000000 +0300
+++ xorgproto-2019.1.mod/include/X11/Xos_r.h	2019-06-29 23:32:10.617173769 +0300
@@ -248,7 +248,7 @@
  */

 #if defined(__NetBSD__) || defined(__FreeBSD__) || defined(__OpenBSD__) || \
-    defined(__APPLE__) || defined(__DragonFly__)
+    defined(__APPLE__) || defined(__DragonFly__) || defined(__ANDROID__)
 static __inline__ void _Xpw_copyPasswd(_Xgetpwparams p)
 {
    memcpy(&(p).pws, (p).pwp, sizeof(struct passwd));
@@ -261,11 +261,7 @@
    (p).len = strlen((p).pwp->pw_passwd);
    strcpy((p).pws.pw_passwd,(p).pwp->pw_passwd);

-   (p).pws.pw_class = (p).pws.pw_passwd + (p).len + 1;
-   (p).len = strlen((p).pwp->pw_class);
-   strcpy((p).pws.pw_class, (p).pwp->pw_class);
-
-   (p).pws.pw_gecos = (p).pws.pw_class + (p).len + 1;
+   (p).pws.pw_gecos = (p).pws.pw_passwd + (p).len + 1;
    (p).len = strlen((p).pwp->pw_gecos);
    strcpy((p).pws.pw_gecos, (p).pwp->pw_gecos);
EOF
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

# Extract source
if [ ! -d "$PKG_SRC_DIR" ]; then
    echo "Extracting $PKG_SRC_FILE..."
    tar -xzf "$PKG_SRC_FILE" -C "$BUILD_DIR/xorgproto" || { echo "Error: Failed to extract $PKG_NAME source"; exit 1; }
fi

# Apply patch (doing this outside the extract conditional to ensure it always runs)
echo "Applying Android compatibility patch..."
cd "$PKG_SRC_DIR"
# The patch might need some offset to apply cleanly as it was written for version 2019.1
patch -p1 --ignore-whitespace -F 3 < "$PKG_PATCH_FILE" || { 
    echo "Warning: Failed to apply patch cleanly, attempting with fuzz and offset";
    patch -p1 --ignore-whitespace -F 3 -f < "$PKG_PATCH_FILE" || {
        echo "Error: Failed to apply patch"; 
        exit 1;
    }
}

# Build
echo "Configuring $PKG_NAME..."
export CC="${CC:-clang}"
export CFLAGS="${CFLAGS} -I$PREFIX/include -I$PREFIX/include/X11"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:$PREFIX/lib/pkgconfig"

# Use autotools as in the original script
./configure \
    --prefix="$PREFIX" \
    --host=aarch64-linux-android \
    --disable-shared \
    --enable-static \
    || { echo "Error: Failed to configure $PKG_NAME"; cat config.log; exit 1; }

# Install
echo "Installing $PKG_NAME to $PREFIX..."
make install || { echo "Error: Failed to install $PKG_NAME"; exit 1; }

# Verify installation
echo "Verifying $PKG_NAME installation..."
if [ -f "$PREFIX/include/X11/X.h" ] && [ -f "$PREFIX/include/X11/Xproto.h" ]; then
    echo "$PKG_NAME installed successfully"
else
    echo "Error: $PKG_NAME headers not installed correctly"
    exit 1
fi

# Copy to output
mkdir -p "$BUILD_TOPDIR/output/$PKG_NAME"
echo "Copying installed headers to output directory..."
cp -r "$PREFIX/include/X11" "$BUILD_TOPDIR/output/$PKG_NAME/"
cp -r "$PREFIX/share/pkgconfig/"*proto*.pc "$BUILD_TOPDIR/output/$PKG_NAME/" 2>/dev/null || true

echo "$PKG_NAME $PKG_VERSION has been successfully installed at $PREFIX"

# Verify installation
echo "Verifying $PKG_NAME installation..."
if [ -f "$PREFIX/include/X11/X.h" ] && [ -f "$PREFIX/include/X11/Xproto.h" ]; then
    echo "$PKG_NAME installed successfully"
else
    echo "Error: $PKG_NAME headers not installed correctly"
    exit 1
fi

# Copy to output
mkdir -p "$BUILD_TOPDIR/output/$PKG_NAME"
echo "Copying installed headers to output directory..."
cp -r "$PREFIX/include/X11" "$BUILD_TOPDIR/output/$PKG_NAME/"
cp -r "$PREFIX/share/pkgconfig/"*proto*.pc "$BUILD_TOPDIR/output/$PKG_NAME/" 2>/dev/null || true

echo "$PKG_NAME $PKG_VERSION has been successfully installed at $PREFIX"
