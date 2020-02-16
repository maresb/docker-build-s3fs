# Reference: https://github.com/s3fs-fuse/s3fs-fuse/wiki/Installation-Notes

# SET COMMIT ID BELOW!!!

FROM ubuntu:18.04

LABEL maintainer="Ben Mares <services-docker-build-s3fs@tensorial.com>" \
      name="docker-build-s3fs" \
      url="https://github.com/maresb/docker-build-s3fs" \
      vcs-url="https://github.com/maresb/docker-build-s3fs"


# Install general build tools

  RUN : \
    && apt-get update \
    && apt-get install -y \
        build-essential \
        fakeroot \
        dpkg-dev \
        devscripts \
        git \
        curl \
;

# Enable source repositories, download package-specific build dependencies,
# and create source tree.

RUN \
    sed -e '/^#\sdeb-src /s/^# *//;t;d' "/etc/apt/sources.list" \
        | tee /etc/apt/sources.list.d/source-repos-tmp.list > /dev/null \
    && apt-get update \
    && apt-get build-dep -y s3fs \
    && apt-get source s3fs

# Download additional dependencies recommended in Wiki installation notes.
# (This is for OpenSSL support.)
RUN \
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

# Add a mechanism to have Docker abandon the cache at this point, by
# calling docker with the arguments
#   --build-arg REBUILD_FROM_HERE=$(date +%s)
ARG REBUILD_FROM_HERE=NO

# SET COMMIT ID HERE!!!
#
###################################
###################################

# The id (either hash or alias) of the default commit to build:
#
ARG COMMIT_ID=v1.86
#
#   Another example:
#     ARG COMMIT_ID=e0712f4

# The latest release of s3fs from the time of the above commit
#
ARG S3FS_VERSION=1.86

# To be increased when there is a change to this Dockerfile which affects the contents
# of the resulting .deb file.  KEEP THIS SYNCHRONIZED WITH ALL BUILD SCRIPTS!!!
#
ARG DEBIAN_PACKAGE_REVISION=2

###################################
###################################

# Build up the version string for the package
ARG PACKAGE_VERSION_STRING=${S3FS_VERSION}+git-${COMMIT_ID}-${DEBIAN_PACKAGE_REVISION}

# These are variables which should be duplicated in build scripts and passed as arguments. 
# Do the corresponding consistency checks.
ARG SCRIPT_DEBIAN_PACKAGE_REVISION=DEBIAN_PACKAGE_REVISION
ARG SCRIPT_PACKAGE_VERSION_STRING=PACKAGE_VERSION_STRING

# Throw an error if they're inconsistent.
RUN : \
 && [ "${SCRIPT_DEBIAN_PACKAGE_REVISION}" = "${DEBIAN_PACKAGE_REVISION}" ] \
 && [ "${SCRIPT_PACKAGE_VERSION_STRING}"  = "${PACKAGE_VERSION_STRING}"  ] \
;




# Download the latest GitHub release, overwriting the original source archive. 
# Then re-extract the original source tree, and update the version.

RUN \
    # Base name of the package, i.e. s3fs-fuse_1.82-1
    PACKAGE_GZ=$(ls *.orig.tar.gz); \
    # Base name of the package, i.e. s3fs-fuse_1.82-1
    PACKAGE_DSC=$(ls *.dsc); \
    # Directory name, i.e. ./s3fs-fuse-1.82
    PACKAGE_DIR=$(find . -maxdepth 1 -name "s3fs-fuse-*" -type d); \
    curl \
      --silent \
      --location \
             https://github.com/s3fs-fuse/s3fs-fuse/tarball/$COMMIT_ID \
      --output \
             $PACKAGE_GZ \
    && rm -rf "$PACKAGE_DIR" \
    && dpkg-source --no-check -x $PACKAGE_DSC \
    && cd "$PACKAGE_DIR" \
    && export DEBFULLNAME="Ben Mares" \
    && export DEBEMAIL="services-docker-build-s3fs@tensorial.com" \
    # Place commit id into file recognized by 'configure.ac'.
    # Otherwise, 's3fs --version' will have an unknown commit because
    # because we are using a source tarball instead of a git-clone.
      && echo "$COMMIT_ID" > default_commit_hash \
    && dch -v "$PACKAGE_VERSION_STRING" "Made by docker-build-s3fs from GitHub using commit ${COMMIT_ID}"


# Build

RUN : \
    && PACKAGE_DIR=$(find . -maxdepth 1 -name "s3fs-fuse-*" -type d) \
    ; cd $PACKAGE_DIR \
    && sed -i 's/libcurl4-gnutls-dev/libcurl4-openssl-dev/g' debian/control \
    && sed -i 's/--with-gnutls/--with-openssl/g' debian/rules \
    && debuild -b -uc -us \
;

# Report info

RUN : \
  && echo \
  && echo \
  && echo "--------------------------------------" \
  && echo "|       .deb CHECKSUM AND SIZE       |" \
  && echo "--------------------------------------" \
  && echo \
  && sha256sum *.deb \
  && echo $(stat -c%s *.deb) bytes \
  && echo \
  && echo "--------------------------------------" \
  && echo "|            md5sums FILE            |" \
  && echo "--------------------------------------" \
  && echo \
  && ar -p *.deb control.tar.xz \
       | tar xJO ./md5sums \
  && echo \
  && echo "--------------------------------------" \
  && echo "|       s3fs CHECKSUM AND SIZE       |" \
  && echo "--------------------------------------" \
  && echo \
  && ar -p *.deb data.tar.xz | tar xJ ./usr/bin/s3fs \
  && echo "$ md5sum /usr/bin/s3fs" \
  && echo "$(md5sum /usr/bin/s3fs)" \
  && echo \
  && echo "$ sha256sum /usr/bin/s3fs" \
  && echo "$(sha256sum /usr/bin/s3fs)" \
  && echo \
  && echo "$ b2sum /usr/bin/s3fs" \
  && echo "$(b2sum /usr/bin/s3fs)" \
  && rm /usr/bin/s3fs \
  && echo \
  && echo "--------------------------------------" \
  && echo "|                DONE                |" \
  && echo "--------------------------------------" \
  && echo \
  && echo \
;
