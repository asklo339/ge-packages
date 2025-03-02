#!/bin/bash
set -e

# Ensure packages directory exists
mkdir -p packages

# Example package list
cat > packages/list.txt << EOL
zlib https://zlib.net/zlib-1.3.1.tar.gz
EOL

# Download each package
while read -r name url; do
    if [ -n "$name" ] && [ -n "$url" ]; then
        echo "Downloading $name from $url"
        wget -O "packages/$name.tar.gz" "$url"
        tar -xzf "packages/$name.tar.gz" -C packages
        mv packages/zlib-* "packages/$name" 2>/dev/null || true
    fi
done < packages/list.txt

echo "Dependencies downloaded."