# Reference: https://github.com/s3fs-fuse/s3fs-fuse/wiki/Installation-Notes

# SET COMMIT ID BELOW!!!

FROM ubuntu:18.04

LABEL maintainer="Ben Mares <services-docker-build-s3fs@tensorial.com>" \
      name="docker-build-s3fs" \
      url="https://github.com/maresb/docker-build-s3fs" \
      vcs-url="https://github.com/maresb/docker-build-s3fs"


# Install general build tools

RUN \
    apt-get update \
    && apt-get install -y \
        build-essential \
        fakeroot \
        dpkg-dev \
        devscripts \
        git \
        curl

# Enable source repositories, download package-specific build dependencies,
# and create source tree.

RUN \
    sed -e '/^#\sdeb-src /s/^# *//;t;d' "/etc/apt/sources.list" \
        | tee /etc/apt/sources.list.d/source-repos-tmp.list > /dev/null \
    && apt-get update \
    && apt-get build-dep -y s3fs \
    && apt-get source s3fs


# SET COMMIT HASH HERE!!!
#
###################################
###################################

# Non-release example:
#ARG COMMIT_ID=e0712f4
#ARG PACKAGE_VERSION_STRING=1.85+git-e0712f4

ARG COMMIT_ID=v1.86
ARG PACKAGE_VERSION_STRING=1.86+git

###################################
###################################

# Download the latest GitHub release, overwriting the original source archive. 
# Then re-extract the original source tree, and update the version.

RUN \
    # Base name of the package, i.e. s3fs-fuse_1.82-1
    PACKAGE_BASE=$(basename $(ls *.dsc) .dsc); \
    # Directory name, i.e. ./s3fs-fuse-1.82
    PACKAGE_DIR=$(find . -maxdepth 1 -name "s3fs-fuse-*" -type d); \
    curl -L \
             https://github.com/s3fs-fuse/s3fs-fuse/tarball/$COMMIT_ID \
         -o \
             $PACKAGE_BASE.orig.tar.gz \
    && rm -rf "$PACKAGE_DIR" \
    && dpkg-source --no-check -x $PACKAGE_BASE.dsc \
    && cd "$PACKAGE_DIR" \
    && export DEBFULLNAME="Ben Mares" \
    && export DEBEMAIL="services-docker-build-s3fs@tensorial.com" \
    && dch -v "$PACKAGE_VERSION_STRING" "Made by docker-build-s3fs from GitHub release"


# Build

RUN \
    PACKAGE_DIR=$(find . -maxdepth 1 -name "s3fs-fuse-*" -type d); \
    cd $PACKAGE_DIR \
    && debuild -b -uc -us

# Report info

RUN sha256sum *.deb && echo $(stat -c%s *.deb) bytes
