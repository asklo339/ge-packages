# Dockerfile
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools and dependencies.
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    unzip \
    pkg-config \
    autoconf \
    automake \
    libtool \
    cmake \
    ninja-build \
    python3 \
    python3-pip

# Set a custom installation prefix.
ENV CUSTOM_PREFIX=/data/data/com.gebox.emu/files/usr/bionic
RUN mkdir -p ${CUSTOM_PREFIX}

# Copy the setup scripts into the container.
COPY ndk-setup.sh /scripts/ndk-setup.sh
COPY mingw-setup.sh /scripts/mingw-setup.sh
RUN chmod +x /scripts/ndk-setup.sh /scripts/mingw-setup.sh

# Optionally run the NDK and mingw setup scripts.
RUN /scripts/ndk-setup.sh && /scripts/mingw-setup.sh

# Copy the rest of the repository into the container.
WORKDIR /workspace
COPY . .

# Set the default command to build the "sample-package".
CMD ["bash", "build-package.sh", "sample-package"]
