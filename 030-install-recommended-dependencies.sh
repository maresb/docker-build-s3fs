#!/bin/bash
set -ex

# Download additional dependencies recommended in Wiki installation notes.
# (This is for OpenSSL support.)

  apt-get update
  apt-get install -y \
    build-essential \
    git \
    libfuse-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    mime-support \
    automake \
    libtool \
    pkg-config \
    libssl-dev \
  ;
