#!/bin/bash
set -ex

apt-get update

apt-get install -y \
  build-essential \
  fakeroot \
  dpkg-dev \
  devscripts \
  git \
  curl \
;

