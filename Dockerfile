FROM ubuntu:20.04

# Install basic tools
RUN apt-get update && apt-get install -y \
    build-essential \
    meson \
    ninja-build \
    wget \
    tar \
    xz-utils \
    python3 \
    python3-pip \
    unzip \
    && rm -rf /var/lib/apt/lists/*


# Upgrade Meson to a version >= 0.59
RUN pip3 install --no-cache-dir meson==1.5.1

# Set up MinGW
COPY mingw-setup.sh .
RUN bash mingw-setup.sh

# Set up Android NDK
COPY ndk-setup.sh .
RUN bash ndk-setup.sh

COPY . .
RUN chmod +x packages/*/build.sh

# Set working directory
WORKDIR /build

# Copy project files
COPY . .

# Default command
CMD ["bash", "build-rootfs.sh", "windows-x86_64"]
