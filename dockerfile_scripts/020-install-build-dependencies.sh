#!/bin/bash
set -ex

# Enable source repositories by uncommenting 'deb-src' lines in 'sources.list'
  sed -e '/^#\sdeb-src /s/^# *//;t;d' "/etc/apt/sources.list" \
    | tee /etc/apt/sources.list.d/source-repos-tmp.list > /dev/null

# Download package-specific build dependencies
  apt-get update
  apt-get build-dep -y s3fs

