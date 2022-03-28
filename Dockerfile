## Compiling doxygen and boost
FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
    cmake \
    build-essential \
    git \
    ca-certificates \
    flex \
    bison \
    python2 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Doxygen
RUN git clone https://github.com/doxygen/doxygen.git \
    && cd doxygen \
    && git checkout Release_1_8_13 \
    && mkdir build \
    && cd build \
    && cmake -G "Unix Makefiles" .. \
    && make -j2 \
    && make install

# Boost
RUN wget https://boostorg.jfrog.io/artifactory/main/release/1.75.0/source/boost_1_75_0.tar.gz \
    && tar -xf boost_1_75_0.tar.gz \
    && cd boost_1_75_0 \
    && ./bootstrap.sh \
    && ./b2 install

# OpenVR
RUN wget https://github.com/ValveSoftware/openvr/archive/refs/tags/v1.16.8.tar.gz \
    && tar -xf v1.16.8.tar.gz


## Copying linuxdeploy
FROM appimagecrafters/docker-linuxdeploy:latest


## Build environment for OpenWalnut
FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
    cmake \
    qtdeclarative5-dev \
    qtwebengine5-dev \
    libqt5opengl5-dev \
    libopenscenegraph-dev \
    libeigen3-dev \
    libnifti-dev \
    zlib1g-dev \
    build-essential \
    python2 \
    python3-pip \
    python3-setuptools \
    texlive-latex-extra \
    ghostscript \
    graphviz \
    wget \
    ca-certificates \
    curl \
    libjpeg62-dev \
    patchelf \
    file \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://sourceforge.net/projects/cxxtest/files/cxxtest/4.4/cxxtest-4.4.tar.gz \
    && tar -xf cxxtest-4.4.tar.gz \
    && cd cxxtest-4.4/python \
    && pip install . \
    && cd ../.. \
    && rm -f cxxtest-4.4.tar.gz


COPY --from=0 /usr/local/bin/doxygen /usr/local/bin/doxygen
COPY --from=0 /usr/local/include/boost/ usr/local/include/boost/
COPY --from=0 /usr/local/lib/libboost*.so /usr/local/lib/
COPY --from=0 /openvr-1.16.8/lib/linux64/libopenvr_api.so /usr/lib/x86_64-linux-gnu
COPY --from=0 /openvr-1.16.8/bin/linux64/ /usr/bin/openvr
COPY --from=0 /openvr-1.16.8/headers/ /usr/include/openvr
COPY --from=1 /usr/local/bin/linuxdeploy /usr/local/bin/linuxdeploy
COPY --from=1 /usr/local/bin/linuxdeploy-plugin-qt /usr/local/bin/linuxdeploy-plugin-qt

RUN for file in /usr/local/lib/libboost*; do ln -s "$file" "$file.1.75.0"; done;

ENV PATH=${PATH}:/cxxtest-4.4
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib

