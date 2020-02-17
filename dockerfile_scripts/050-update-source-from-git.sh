#!/bin/bash
set -ex

# Set Debian packaging contact info

  export DEBFULLNAME="Ben Mares"
  export DEBEMAIL="services-docker-build-s3fs@tensorial.com"


# Verify that any script parameters are consistent with those in this Dockerfile.

  [ "${SCRIPT_DEBIAN_PACKAGE_REVISION}" = "${DEBIAN_PACKAGE_REVISION}" ]
  [ "${SCRIPT_PACKAGE_VERSION_STRING}"  = "${PACKAGE_VERSION_STRING}"  ]


# Download the latest GitHub release, overwriting the original source archive. 
# Then re-extract the original source tree, and update the version.

  # Base name of the package, i.e. s3fs-fuse_1.82-1

    PACKAGE_GZ=$(ls *.orig.tar.gz);


  # Base name of the package, i.e. s3fs-fuse_1.82-1

    PACKAGE_DSC=$(ls *.dsc);


  # Directory name, i.e. ./s3fs-fuse-1.82

    PACKAGE_DIR=$(find . -maxdepth 1 -name "s3fs-fuse-*" -type d);


  # Download the tarball from GitHub, replacing old source tarball

    curl \
      --silent \
      --location \
           https://github.com/s3fs-fuse/s3fs-fuse/tarball/$COMMIT_ID \
      --output \
           $PACKAGE_GZ


  # Delete outdated package directory

    rm -rf "$PACKAGE_DIR"


  # Reextract package with the new tarball

    dpkg-source --no-check -x $PACKAGE_DSC


  # Change into package directory

    cd "$PACKAGE_DIR"
    

  # Place commit id into file recognized by 'configure.ac'.
  # Otherwise, 's3fs --version' will have an unknown commit because
  # because we are using a source tarball instead of a git-clone.

    echo "$COMMIT_ID" > default_commit_hash


  # Update the changelog with the new version

    dch -v "$PACKAGE_VERSION_STRING" "Made by docker-build-s3fs from GitHub using commit ${COMMIT_ID}"

