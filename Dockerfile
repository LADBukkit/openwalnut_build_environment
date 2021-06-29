## Compiling doxygen
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
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/doxygen/doxygen.git \
    && cd doxygen \
    && git checkout Release_1_8_13 \
    && mkdir build \
    && cd build \
    && cmake -G "Unix Makefiles" .. \
    && make -j2 \
    && make install


## Copying linuxdeploy
FROM appimagecrafters/docker-linuxdeploy:latest


## Build environment for OpenWalnut
FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
    cmake \
    libboost-all-dev \
    qtdeclarative5-dev \
    qtwebengine5-dev \
    libqt5opengl5-dev \
    libopenscenegraph-dev \
    libeigen3-dev \
    libnifti-dev \
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
    && rm -rf /var/lib/apt/lists/*

RUN wget https://sourceforge.net/projects/cxxtest/files/cxxtest/4.4/cxxtest-4.4.tar.gz \
    && gunzip cxxtest-4.4.tar.gz \
    && tar -xf cxxtest-4.4.tar \
    && cd cxxtest-4.4/python \
    && pip install .

COPY --from=0 /usr/local/bin/doxygen /usr/local/bin/doxygen
COPY --from=1 /usr/local/bin/linuxdeploy /usr/local/bin/linuxdeploy
COPY --from=1 /usr/local/bin/linuxdeploy-plugin-qt /usr/local/bin/linuxdeploy-plugin-qt
#COPY --from=1 /usr/local/bin/linuxdeploy-plugin-qt /usr/local/bin/linuxdeploy-plugin-appimage

ENV PATH=${PATH}:/cxxtest-4.4

