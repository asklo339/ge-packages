FROM ubuntu:20.04

# Install basic tools
RUN apt-get update && apt-get install -y \
    build-essential \
    meson \
    ninja-build \
    wget \
    tar \
    xz-utils \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set up MinGW
COPY mingw-setup.sh .
RUN bash mingw-setup.sh

# Set up Android NDK
COPY ndk-setup.sh .
RUN bash ndk-setup.sh

# Set working directory
WORKDIR /build

# Copy project files
COPY . .

# Default command
CMD ["bash", "build-rootfs.sh", "windows-x86_64"]